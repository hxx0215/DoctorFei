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
@interface ContactGroupNewLocationViewController ()
    <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, UITableViewDelegate, UITableViewDataSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ContactGroupNewLocationViewController
{
    BMKLocationService *locationService;
    BMKGeoCodeSearch *geoSearch;
    BOOL isCanLocate, isCanPOI, poiHasResult;
    NSArray *infoArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isCanLocate = YES;
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
    if (error == BMK_SEARCH_NO_ERROR) {
        poiHasResult = YES;
        infoArray = result.poiList;
    }else{
        poiHasResult = NO;
    }
    [self.tableView reloadData];
}

@end
