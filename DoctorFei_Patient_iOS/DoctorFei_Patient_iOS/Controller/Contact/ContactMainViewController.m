//
//  ContactMainViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/28.
//
//

#import "ContactMainViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "ContactFriendTableViewCell.h"
@interface ContactMainViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ContactMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setTableFooterView:[UIView new]];
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

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactFriendCellIdentifier = @"ContactFriendCellIdentifier";
    ContactFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactFriendCellIdentifier forIndexPath:indexPath];
    return cell;
}

@end
