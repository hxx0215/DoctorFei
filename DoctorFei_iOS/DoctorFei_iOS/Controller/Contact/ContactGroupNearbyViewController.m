//
//  ContactGroupNearbyViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/3.
//
//

#import "ContactGroupNearbyViewController.h"
#import <MJRefresh.h>
#import "ContactGroupNearbyTableViewCell.h"
#import "ChatAPI.h"
#import <BaiduMapAPI/BMapKit.h>
#import <UIImageView+WebCache.h>
#define kGroupNearbyPageSize 10
static NSString *ContactGroupNearbyCellIdentifier = @"ContactGroupNearbyCellIdentifier";

@interface ContactGroupNearbyViewController ()
    <UITableViewDelegate, UITableViewDataSource, BMKLocationServiceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ContactGroupNearbyViewController
{
    NSMutableArray *nearbyArray;
    int pageNum;
    BMKLocationService *locationService;
    CLLocationCoordinate2D currentLocation;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [BMKLocationService setLocationDistanceFilter:100.f];
    locationService = [[BMKLocationService alloc]init];
    locationService.delegate = self;
    [locationService startUserLocationService];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    pageNum = 1;
    nearbyArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchNearbyGroupByPage:(int)page {
    NSDictionary *param = @{
                            @"lng": @(currentLocation.longitude),
                            @"lat": @(currentLocation.latitude),
                            @"pageIndex": @(page),
                            @"pageSize": @(kGroupNearbyPageSize)
                            };
    [ChatAPI searchGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject count] > 0) {
            [nearbyArray addObjectsFromArray:responseObject];
            pageNum ++;
            [self.tableView.footer endRefreshing];
        }else{
            [self.tableView.footer noticeNoMoreData];
            [self.tableView.footer performSelector:@selector(setHidden:) withObject:@YES afterDelay:1.0f];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}


#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return nearbyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactGroupNearbyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactGroupNearbyCellIdentifier forIndexPath:indexPath];
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:nearbyArray[indexPath.row][@"icon"] ] placeholderImage:[UIImage imageNamed:@"group_preinstall_pic"]];
//    [cell.addressLabel setText:nearbyArray[indexPath.row][@"address"]];
    [cell.distanceLabel setText:[nearbyArray[indexPath.row][@"distance"]stringValue]];
    [cell.nameLabel setText:[NSString stringWithFormat:@"%@(%@)",nearbyArray[indexPath.row][@"name"], [nearbyArray[indexPath.row][@"total"]stringValue]]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - BMKLocation Delegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    currentLocation = userLocation.location.coordinate;
    [locationService stopUserLocationService];
    [self fetchNearbyGroupByPage:pageNum];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [self fetchNearbyGroupByPage:pageNum];
    }];
    [self.tableView.footer beginRefreshing];
}
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"Get Location Error: %@",error.localizedDescription);
}


@end
