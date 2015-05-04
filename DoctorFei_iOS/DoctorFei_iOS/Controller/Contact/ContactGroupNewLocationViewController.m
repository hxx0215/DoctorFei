//
//  ContactGroupNewLocationViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/3.
//
//

#import "ContactGroupNewLocationViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "ContactGroupNewLocationTableViewCell.h"
#import <UIScrollView+EmptyDataSet.h>
@interface ContactGroupNewLocationViewController ()
    <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)nextButtonClicked:(id)sender;
@end

@implementation ContactGroupNewLocationViewController
{
    BMKLocationService *locationService;
    BMKGeoCodeSearch *geoSearch;
    BOOL isCanLocate, isCanPOI, isLoading;
    NSArray *infoArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isCanLocate = YES;
    isCanPOI = YES;
    isLoading = YES;
    // Do any additional setup after loading the view.
    [self.tableView setTableFooterView:[UIView new]];

    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [BMKLocationService setLocationDistanceFilter:100.f];
    locationService = [[BMKLocationService alloc]init];
    locationService.delegate = self;
    [locationService startUserLocationService];

    geoSearch = [[BMKGeoCodeSearch alloc]init];
    geoSearch.delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated {
    locationService.delegate = nil;
    geoSearch.delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return infoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactGroupNewLocationCellIdentifier = @"ContactGroupNewLocationCellIdentifier";
    ContactGroupNewLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactGroupNewLocationCellIdentifier forIndexPath:indexPath];
    BMKPoiInfo *info = infoArray[indexPath.row];
    [cell.nameLabel setText:info.name];
    [cell.addressLabel setText:info.address];
    return cell;
}
#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - BMKLocation Delegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    isCanLocate = YES;
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [locationService stopUserLocationService];
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc]init];
    option.reverseGeoPoint = userLocation.location.coordinate;
    isCanPOI = [geoSearch reverseGeoCode:option];
}
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"Get Location Error: %@",error.localizedDescription);
    isCanLocate = NO;
}

#pragma mark - BMKGeoCode Delegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    isLoading = NO;
    if (error == BMK_SEARCH_NO_ERROR) {
        infoArray = result.poiList;
    }
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - DZNEmprtDatasource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *string;
    if (!isCanLocate) {
        string = @"无法获取您的位置";
    }else if (!isCanPOI) {
        string = @"无法获取周边兴趣点";
    }else if (isLoading) {
        string = @"正在加载...";
    }else {
        string = @"周边无兴趣点";
    }
    return [[NSAttributedString alloc]initWithString:string];
}

- (IBAction)nextButtonClicked:(id)sender {
    
}
@end
