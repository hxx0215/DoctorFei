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
#import "UIScrollView+EmptyDataSet.h"
#import "ContactGroupRemoteDetailViewController.h"
#define kGroupNearbyPageSize 10

static NSString *ContactGroupNearbyCellIdentifier = @"ContactGroupNearbyCellIdentifier";

@interface ContactGroupNearbyViewController ()
    <UITableViewDelegate, UITableViewDataSource, BMKLocationServiceDelegate, DZNEmptyDataSetSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ContactGroupNearbyViewController
{
    NSMutableArray *nearbyArray;
    int pageNum;
    BMKLocationService *locationService;
    CLLocationCoordinate2D currentLocation;
    BOOL isCanLocate;
}
- (void)viewDidLoad {

    [super viewDidLoad];
    isCanLocate = YES;
    // Do any additional setup after loading the view.
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [BMKLocationService setLocationDistanceFilter:100.f];
        locationService = [[BMKLocationService alloc]init];
        locationService.delegate = self;
        [locationService startUserLocationService];
    }else{
        isCanLocate = NO;
    }
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView reloadData];
    pageNum = 1;
    nearbyArray = [NSMutableArray array];
}

- (void)viewWillDisappear:(BOOL)animated {
    locationService.delegate = nil;
    [super viewWillDisappear:animated];
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
    if ([nearbyArray[indexPath.row][@"address"] isKindOfClass:[NSString class]]) {
        [cell.addressLabel setText:nearbyArray[indexPath.row][@"address"]];
    }else{
        [cell.addressLabel setText:@""];
    }
    [cell.distanceLabel setText:[NSString stringWithFormat:@"%@m",[nearbyArray[indexPath.row][@"distance"]stringValue]]];
    [cell.nameLabel setText:[NSString stringWithFormat:@"%@(%@)",nearbyArray[indexPath.row][@"name"], [nearbyArray[indexPath.row][@"total"]stringValue]]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactGroupInfoSegueIdentifier"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        ContactGroupRemoteDetailViewController *vc = [segue destinationViewController];
        [vc setGroupId:@([nearbyArray[indexPath.row][@"groupid"]intValue])];
        [vc setLongtitude:@(currentLocation.longitude)];
        [vc setLatitude:@(currentLocation.latitude)];
    }
}

#pragma mark - BMKLocation Delegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    isCanLocate = YES;
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
    isCanLocate = NO;
    [self.tableView reloadData];
}

#pragma mark - DZNEmptyDatasource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (isCanLocate) {
        return [[NSAttributedString alloc]initWithString:@"暂无附近的群"];
    }else{
        return [[NSAttributedString alloc]initWithString:@"无法获取位置"];
    }
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
