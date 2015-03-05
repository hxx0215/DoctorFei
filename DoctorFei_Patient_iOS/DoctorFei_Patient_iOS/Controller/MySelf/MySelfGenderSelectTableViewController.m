//
//  MySelfGenderSelectTableViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/5.
//
//

#import "MySelfGenderSelectTableViewController.h"

@interface MySelfGenderSelectTableViewController ()
- (IBAction)backButtonClicked:(id)sender;

@end

@implementation MySelfGenderSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(genderSelectVC:selectGender:)]) {
        [self.delegate genderSelectVC:self selectGender:@(indexPath.row)];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
