//
//  QuickReplyTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/13.
//
//

#import "QuickReplyTableViewController.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import "QuickReplyCustomActionTableViewCell.h"
#import "QuickReplyTableViewCell.h"
#import "QuickReplyAddCustomViewController.h"
@interface QuickReplyTableViewController ()

- (IBAction)backButtonClicked:(id)sender;

@end

@implementation QuickReplyTableViewController
{
    NSArray *replyDicArry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFastReply];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadFastReply
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DoctorAPI getDoctorFastreplyWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        replyDicArry = [responseObject copy];
        [self.tableView reloadData];
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [replyDicArry count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *QuickReplyCellIdentifier = @"QuickReplyCellIdentifier";
    static NSString *QuickReplyCustomCellIdentifier = @"QuickReplyCustomCellIdentifier";
    if (indexPath.row < replyDicArry.count) {
        QuickReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QuickReplyCellIdentifier forIndexPath:indexPath];
        [cell setReplyContent:replyDicArry[indexPath.row][@"content"]];
        return cell;
    } else{
        QuickReplyCustomActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QuickReplyCustomCellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

@end
