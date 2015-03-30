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
@interface OrganDisplayViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,androidTableViewDelegate,androidTableViewDataSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AndroidTableView *androidTableView;
@end

@implementation OrganDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setTableFooterView:[UIView new]];
    self.androidTableView = [[AndroidTableView alloc] initWithFrame:self.view.bounds];
    self.androidTableView.delegate =self;
    self.androidTableView.dataSource = self;
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


#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *OrganDisplayCellIdentifier = @"OrganDisplayCellIdentifier";
    OrganDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OrganDisplayCellIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}

#pragma mark - androidTableViewDelegate &DataSource
- (NSInteger)androidTableView:(AndroidTableView *)androidTableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSString *)androidTableView:(AndroidTableView *)androidTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"河南";
}
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)titleButtonClicked:(UIButton *)sender {
    [self.androidTableView showInView:self.view.window];
}
@end
