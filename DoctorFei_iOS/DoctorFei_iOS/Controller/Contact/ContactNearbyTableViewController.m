//
//  ContactNearbyTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/13/15.
//
//

#import "ContactNearbyTableViewController.h"
#import "ContactNearbyTableViewCell.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import <CoreLocation/CoreLocation.h>
#import <UIScrollView+EmptyDataSet.h>
#define Contact_PageSize 10
@interface ContactNearbyTableViewController ()
    <CLLocationManagerDelegate, DZNEmptyDataSetSource>
@end

@implementation ContactNearbyTableViewController
{
    MBProgressHUD *hud;
    NSMutableArray *tableViewDicArray;
    NSInteger pageIndex;
    NSInteger lastSize;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [UIView new];
    
    tableViewDicArray = [[NSMutableArray alloc]init];
    pageIndex = 1;
    lastSize = Contact_PageSize;
    
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    if ([CLLocationManager locationServicesEnabled]) {
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        } else {
            [locationManager startUpdatingLocation];
        }
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self searchFrind];
}

-(void)loadMore
{
    if (lastSize!=Contact_PageSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView footerEndRefreshing];
        });
        return ;//已到最后。返回
    }
    pageIndex++;
    [self searchFrind];
}

-(void)searchFrind
{
//    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"type": @0,
                             @"userid": [userId stringValue],
                             //@"usertype": @1,
                             @"lng": @(currentLocation.coordinate.longitude),
                             @"lat": @(currentLocation.coordinate.latitude),
                             @"pageSize": @Contact_PageSize,
                             @"pageIndex": [NSNumber numberWithInteger:pageIndex]
                             };
    NSLog(@"%@",params);
    [DoctorAPI searchFriendWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *dataArray = (NSArray *)responseObject;
        for (NSDictionary *dict in dataArray) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
            [tableViewDicArray addObject:dic];
        }
        lastSize = [dataArray count];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hide:YES];
            [self.tableView footerEndRefreshing];
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView footerEndRefreshing];
        });
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [tableViewDicArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactNearbyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactNearbyCellIdentifier" forIndexPath:indexPath];
    [cell setDataDic:[tableViewDicArray objectAtIndex:indexPath.row]];
    // Configure the cell...
    
    return cell;
}


#pragma mark - CLLocation Delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    currentLocation = locations.lastObject;
    __weak typeof(self) wself = self;
    [self.tableView addFooterWithCallback:^{
        typeof(self) sself = wself;
        [sself loadMore];
    }];
    [self searchFrind];
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorized) {
        [manager startUpdatingLocation];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您没有授权费医生使用您的位置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - DZNEmptyDatasource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无数据"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
