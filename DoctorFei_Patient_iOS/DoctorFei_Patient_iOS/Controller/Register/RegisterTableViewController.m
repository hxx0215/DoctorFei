//
//  RegisterTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "RegisterTableViewController.h"
#import "RegisterAPI.h"
#import <MBProgressHUD.h>
#import "DeviceUtil.h"
#import <ReactiveCocoa.h>
#import "RegisterMoreTableViewController.h"
static const NSTimeInterval kDuration = 60;

@interface RegisterTableViewController ()
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *capthaTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTextField;
@property (weak, nonatomic) IBOutlet UIButton *getCapthaButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)getCapthaButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end

@implementation RegisterTableViewController
{
    NSTimer *countDownTimer;
    long timeCount;
    int currentUserId;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    timeCount = 0;
    NSNumber *recordTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"LastTimeGetCapthaTime"];
    if (recordTime) {
        long nowTime = [[NSDate date]timeIntervalSince1970];
        long interval = (nowTime - [recordTime longValue]);
        if (interval > kDuration) {
//            [self.getCapthaButton setEnabled:YES];
            [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        }
        else{
            [self.getCapthaButton setEnabled:NO];
            [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
            timeCount = kDuration - interval;
            [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
            countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (countDownTimer) {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    [self.phoneTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.passwordAgainTextField resignFirstResponder];
    [self.capthaTextField resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    CGRect tableViewFooterFrame = self.tableView.tableFooterView.frame;
    tableViewFooterFrame.size.height = 78.0f;
    [self.tableView.tableFooterView setFrame:tableViewFooterFrame];
    RAC(self.getCapthaButton, enabled) = [RACSignal combineLatest:@[self.phoneTextField.rac_textSignal] reduce:^(NSString *phone){
        if (phone.length == 11 && timeCount == 0) {
            [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
            return @(YES);
        }
        else{
            return @(NO);
        }
    }];
    RAC(self.nextButton, enabled) = [RACSignal combineLatest:@[self.phoneTextField.rac_textSignal, self.capthaTextField.rac_textSignal, self.passwordTextField.rac_textSignal, self.passwordAgainTextField.rac_textSignal] reduce:^(NSString *phone, NSString *captha, NSString *password, NSString *passwordAgain){
        return @(phone.length == 11 && captha.length == 6 && password.length > 0 && [passwordAgain isEqualToString:password]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RegisterNextSegueIdentifier"]) {
        RegisterMoreTableViewController *vc = [segue destinationViewController];
        [vc setUserId:currentUserId];
    }
//    //仅供调试下一步专用
//    else if ([segue.identifier isEqualToString:@"DebugMoreSegueIdentifier"]) {
//        RegisterMoreTableViewController *vc = [segue destinationViewController];
//        [vc setUserId:33];
//    }
}

#pragma mark - Actions
- (void)countDown
{
    timeCount --;
    if (timeCount > 0) {
        [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
    }
    else{
        [self.getCapthaButton setEnabled:YES];
        [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)getCapthaButtonClicked:(id)sender {
    long nowTime = [[NSDate date]timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults]setObject:@(nowTime) forKey:@"LastTimeGetCapthaTime"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.getCapthaButton setEnabled:NO];
    [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
    timeCount = kDuration;
    [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"获取验证码中..."];
    
    //获取验证码请求
    NSDictionary *params = @{@"mobile": self.phoneTextField.text, @"type": @"0"};
    [RegisterAPI getCpathaWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"获取成功";
            hud.detailsLabelText = dataDict[@"msg"];
        }
        else{
            hud.labelText = @"获取错误";
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

- (IBAction)nextButtonClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"提交注册申请中..."];
    NSDictionary *params = @{
                             @"mobile": self.phoneTextField.text,
                             @"code": self.capthaTextField.text,
                             @"password": self.passwordTextField.text,
                             @"SN": [DeviceUtil getUUID]
                             };//[DeviceUtil getUUID]
    [RegisterAPI registerWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = dataDict[@"msg"];
            currentUserId = [dataDict[@"userid"]intValue];
            [self performSegueWithIdentifier:@"RegisterNextSegueIdentifier" sender:nil];
        }
        else{
            hud.labelText = @"注册错误";
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
@end
