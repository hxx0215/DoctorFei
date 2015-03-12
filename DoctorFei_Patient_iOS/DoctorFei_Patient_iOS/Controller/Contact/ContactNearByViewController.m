//
//  ContactNearByViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/12.
//
//
@import CoreLocation;
#import "ContactNearByViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import <MBProgressHUD.h>
#import "ContactNearByTableViewCell.h"
#import <MJRefresh.h>
#import "UserAPI.h"
#import "MemberAPI.h"

#define Contact_PageSize 15
@interface ContactNearByViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, CLLocationManagerDelegate>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ContactNearByViewController
{
    NSMutableArray *dataArray;
    NSInteger pageIndex;
    NSInteger lastSize;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setTableFooterView:[UIView new]];
    dataArray = [NSMutableArray array];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadMore
{
    if (lastSize!=Contact_PageSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.footer endRefreshing];
            [self.tableView.footer noticeNoMoreData];
        });
        return ;//已到最后。返回
    }
    pageIndex++;
    [self searchFriend];
}

-(void)searchFriend
{
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"type": @0,
                             @"userid": [userId stringValue],
                             @"usertype": @-1,
                             @"lng": @(currentLocation.coordinate.longitude),
                             @"lat": @(currentLocation.coordinate.latitude),
                             @"pageSize": @Contact_PageSize,
                             @"pageIndex": [NSNumber numberWithInteger:pageIndex]
                             };
    NSLog(@"%@",params);
    [UserAPI searchUserWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [dataArray addObjectsFromArray:(NSArray *)responseObject];
        lastSize = [responseObject count];
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [hud hide:YES];
            [self.tableView.footer endRefreshing];
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.footer endRefreshing];
        });
    }];
}

- (void)setFriendWithFriendId:(NSNumber *)friendId andUserType:(NSNumber *)userType {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"friendid": friendId,
                            @"usertype": userType
                            };
    [MemberAPI setFriendWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = [responseObject firstObject];
        if ([dic[@"state"] integerValue]==1) {
            UIImageView *completeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_prompt-01_pic.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.dimBackground = YES;
            hud.customView = completeImage;
        }else{
            hud.mode = MBProgressHUDModeText;
        }
        hud.detailsLabelText = dic[@"msg"];//NSLocalizedString(@"好友添加成功", nil);
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactNearbyCellIdentifier = @"ContactNearbyCellIdentifier";
    ContactNearByTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactNearbyCellIdentifier forIndexPath:indexPath];
    [cell setDataDict:dataArray[indexPath.row]];
    [cell.addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.addButton setTag:indexPath.row];
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}
#pragma mark - DZNEmptyDatasource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无结果"];
}

#pragma mark - Actions

- (void)addButtonClicked:(UIButton *)sender {
    NSDictionary *data = dataArray[sender.tag];
    [self setFriendWithFriendId:data[@"userid"] andUserType:data[@"usertype"]];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CLLocation Delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    currentLocation = locations.lastObject;
    __weak typeof(self) wself = self;
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        typeof(self) sself = wself;
        [sself loadMore];
    }];
    [self searchFriend];
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorized) {
        [manager startUpdatingLocation];
        
    }else if(status == kCLAuthorizationStatusDenied){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您没有授权费医生使用您的位置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
