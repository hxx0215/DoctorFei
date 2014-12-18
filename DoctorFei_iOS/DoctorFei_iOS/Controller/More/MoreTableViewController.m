//
//  MoreTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "MoreTableViewController.h"
#import "DoctorAPI.h"
#import "DataUtil.h"
#import <MBProgressHUD.h>
@interface MoreTableViewController ()
    <UIAlertViewDelegate, UIGestureRecognizerDelegate>

- (IBAction)logoutButtonClicked:(id)sender;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    
    CGRect tableViewHeaderRect = self.tableView.tableHeaderView.frame;
    tableViewHeaderRect.size.height = 134.0f;
    [self.tableView.tableHeaderView setFrame:tableViewHeaderRect];
    
    
    CGRect tableViewFooterRect = self.tableView.tableFooterView.frame;
    tableViewFooterRect.size.height = 78.0f;
    [self.tableView.tableFooterView setFrame:tableViewFooterRect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logoutAction {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"退出登录中..."];
    NSDictionary *params = @{
                             @"doctorid": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],
                             @"online": @(0)
                             };
    [DoctorAPI onlineWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
//        NSLog(@"%@",dataDict);
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            [hud hide:YES];
//            hud.labelText = @"退出登录成功";
            [DataUtil cleanUserDefault];
            [self.tabBarController setSelectedIndex:0];
            [self.tabBarController performSegueWithIdentifier:@"LoginSegueIdentifier" sender:nil];
        }
        else{
            hud.labelText = @"退出登录错误";
            hud.detailsLabelText = dataDict[@"msg"];
        }
        [hud hide:YES afterDelay:1.5f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}


#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logoutButtonClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确认退出登录?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self logoutAction];
    }
}
@end
