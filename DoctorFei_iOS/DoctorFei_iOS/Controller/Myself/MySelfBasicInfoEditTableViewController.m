//
//  MySelfBasicInfoEditTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/3.
//
//

#define kUserDefaultKeyDict @{@"headimage": @"UserIcon", @"realname": @"UserRealName", @"hospital": @"UserHospital", @"department": @"UserDepartment", @"jobtitle": @"UserJobTitle", @"email": @"UserEmail"}

#import "MySelfBasicInfoEditTableViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
@interface MySelfBasicInfoEditTableViewController ()
    <UITextFieldDelegate, UITableViewDelegate>
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *infoTextField;

@end

@implementation MySelfBasicInfoEditTableViewController
@synthesize name = _name, key = _key;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.title = [NSString stringWithFormat:@"修改%@", _name];
    [self.infoTextField setPlaceholder:[NSString stringWithFormat:@"请输入您的%@", _name]];
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[_infoTextField.rac_textSignal] reduce:^(NSString *info){
        return @(info.length > 0);
    }];
    [self.infoTextField setText:_value];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.infoTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.infoTextField resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (void)updateInfo {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"提交注册申请中..."];
    NSNumber *currentUserId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSString *currentInfo = [self.infoTextField.text copy];
    NSDictionary *params = @{
                             @"doctorid": currentUserId,
                             _key: currentInfo
                             };
    [DoctorAPI updateInfomationWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"修改成功";
            [[NSUserDefaults standardUserDefaults]setObject:currentInfo forKey:kUserDefaultKeyDict[_key]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            hud.labelText = @"修改错误";
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

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonClicked:(id)sender {
    [self updateInfo];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        [self updateInfo];
    }
    return YES;
}


#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}
@end
