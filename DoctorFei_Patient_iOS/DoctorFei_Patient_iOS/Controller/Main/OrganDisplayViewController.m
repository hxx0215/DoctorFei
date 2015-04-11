//
//  OrganDisplayViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/27.
//
//

#import "OrganDisplayViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "OrganDisplayTableViewCell.h"
#import "DOPDropDownMenu.h"
#import "DoctorFei_Patient_iOS-Swift.h"
#import "MemberAPI.h"
@interface OrganDisplayViewController ()
<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, androidTableViewDelegate, androidTableViewDataSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AndroidTableView *androidTableView;
@property (strong, nonatomic) NSMutableArray *cityData;
@property (strong, nonatomic) NSMutableArray *areaData;
@property (weak, nonatomic) IBOutlet UIButton *cityButton;
@property (weak, nonatomic) IBOutlet UIButton *areaButton;
@property (copy, nonatomic) NSString *currentCity;
@property (copy, nonatomic) NSString *currentArea;
@property (strong, nonatomic) NSMutableArray *tableData;
@end


@implementation OrganDisplayViewController
@synthesize currentCity = _currentCity;
@synthesize currentArea = _currentArea;
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.tableView setTableFooterView:[UIView new]];
	self.androidTableView = [[AndroidTableView alloc] initWithFrame:self.view.bounds];
	self.androidTableView.delegate = self;
	self.androidTableView.dataSource = self;
	[self.androidTableView.cityButton addTarget:self action:@selector(citySelected:) forControlEvents:UIControlEventTouchUpInside];
	[self.androidTableView.areaButton addTarget:self action:@selector(areaSelected:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.type == OrganTypeShow)
		[self refreshData:@"15"];//默认15河南，182郑州;
	if (self.type == OrganTypeOutstanding) {
		self.tableViewTopConstraint.constant = 0.0;
		self.filterView.hidden = YES;
		self.cityButton.hidden = YES;
		self.areaButton.hidden = YES;
		[self getDisplayData];
	}
    if (self.type == OrganTypeNursing){
        [self refreshData:@"15"];
    }
}

- (void)refreshData:(NSString *)cityId {
	NSDictionary *params = @{ @"area": cityId };
	[MemberAPI getAreaListWithParameters:params success: ^(AFHTTPRequestOperation *operation, id responseObject) {
	    self.cityData = [responseObject mutableCopy];
	    self.areaData = [[[responseObject firstObject] objectForKey:@"data"] mutableCopy];
	    self.currentCity = @"182";
	    self.currentArea = @"1247";
	    [self getDisplayData];
	} failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)getDisplayData {
	if (self.type == OrganTypeShow) {
		NSDictionary *params = @{ @"id": @"0",
			                      @"cid": _currentCity,
			                      @"rid": _currentArea };
		[MemberAPI getOrgListWithParameters:params success: ^(AFHTTPRequestOperation *operation, id responseObject) {
		    self.tableData = responseObject;
		    [self.tableView reloadData];
		} failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
		}];
	}
	if (self.type == OrganTypeOutstanding) {
		NSDictionary *params = @{ @"id": @"0" };
		[MemberAPI getOutStandingSampleWithParameters:params success: ^(AFHTTPRequestOperation *operation, id responseObject) {
		    self.tableData = responseObject;
		    [self.tableView reloadData];
		} failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
		}];
	}
    if (self.type == OrganTypeNursing){
        NSDictionary *params = @{@"id": @"0",
                                 @"cid": _currentCity,
                                 @"rid": _currentArea};
        [MemberAPI getNursingWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
            self.tableData = responseObject;
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];
    }
}

- (void)setCurrentCity:(NSString *)currentCity {
	_currentCity = currentCity;
	[self.cityButton setTitle:self.currentCity forState:UIControlStateNormal];
}

- (void)setCurrentArea:(NSString *)currentArea {
	_currentArea = currentArea;
	[self.areaButton setTitle:self.currentArea forState:UIControlStateNormal];
}

- (NSString *)currentCity {
	for (id obj in self.cityData) {
		if ([obj[@"areaid"] isEqualToString:_currentCity])
			return obj[@"name"];
	}
	return @"";
}

- (NSString *)currentArea {
	for (id obj in self.areaData) {
		if ([obj[@"areaid"] isEqualToString:_currentArea])
			return obj[@"name"];
	}
	return @"";
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *OrganDisplayCellIdentifier = @"OrganDisplayCellIdentifier";
    OrganDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OrganDisplayCellIdentifier  forIndexPath:indexPath];
    [cell setCellData:self.tableData[indexPath.row] withType:self.type];
	return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 77.0f;
}

#pragma mark - androidTableViewDelegate &DataSource
- (NSInteger)androidTableView:(AndroidTableView *)androidTableView numberOfRowsInSection:(NSInteger)section {
	if (self.androidTableView.cityButton.selected)
		return [self.cityData count];
	else
		return [self.areaData count];
}

- (NSString *)androidTableView:(AndroidTableView *)androidTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.androidTableView.cityButton.selected)
		return [self.cityData[indexPath.row] objectForKey:@"name"];
	else
		return [self.areaData[indexPath.row] objectForKey:@"name"];
}

- (void)androidTableView:(AndroidTableView *)androidTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.androidTableView.cityButton.selected) {
		self.currentCity = self.cityData[indexPath.row][@"areaid"];
		self.areaData = self.cityData[indexPath.row][@"data"];
		self.currentArea = [[self.areaData firstObject] objectForKey:@"areaid"];
	}
	else {
		self.currentArea = [self.areaData[indexPath.row] objectForKey:@"areaid"];
	}
	[self getDisplayData];
	[self.androidTableView dismiss];
}

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)titleButtonClicked:(UIButton *)sender {
	[self.androidTableView showInView:self.view.window];
	if (self.cityButton == sender)
		[self citySelected:nil];
	else
		[self areaSelected:nil];
	self.androidTableView.currentArea = self.currentArea;
	self.androidTableView.currentCity = self.currentCity;
}

- (void)citySelected:(UIButton *)sender {
	self.androidTableView.cityButton.selected = YES;
	self.androidTableView.areaButton.selected = NO;
	[self.androidTableView.tableView reloadData];
}

- (void)areaSelected:(UIButton *)sender {
	self.androidTableView.cityButton.selected = NO;
	self.androidTableView.areaButton.selected = YES;
	[self.androidTableView.tableView reloadData];
}

@end
