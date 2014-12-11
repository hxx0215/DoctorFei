//
//  SetNewPasswordTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/23.
//
//

#import "SetNewPasswordTableViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "RegisterAPI.h"

static const NSTimeInterval kDuration = 60;
@interface SetNewPasswordTableViewController ()

- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *currentPhoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *capthaTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *getCapthaButton;
- (IBAction)confirmButtonClicked:(id)sender;
- (IBAction)getCapthaButtonClicked:(id)sender;

@end

@implementation SetNewPasswordTableViewController
{
    NSTimer *countDownTimer;
    long timeCount;
}
@synthesize currentPhone = _currentPhone;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    timeCount = 0;
    NSNumber *recordTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"LastTimeGetCapthaTime"];
    if (recordTime) {
        long nowTime = [[NSDate date]timeIntervalSince1970];
        long interval = (nowTime - [recordTime longValue]);
        if (interval <= kDuration) {
            [self.getCapthaButton setEnabled:NO];
            timeCount = kDuration - interval;
            [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
            countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    if (countDownTimer) {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    [self.capthaTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.passwordAgainTextField resignFirstResponder];
    [super viewWillDisappear:animated];
}
- (void)countDown
{
    timeCount --;
    if (timeCount > 0) {
        [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
    }
    else{
        [self.getCapthaButton setEnabled:YES];
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    CGRect tableViewFooterFrame = self.tableView.tableFooterView.frame;
    tableViewFooterFrame.size.height = 120.0f;
    [self.tableView.tableFooterView setFrame:tableViewFooterFrame];
    
    [self.currentPhoneLabel setText:_currentPhone];
    
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.capthaTextField.rac_textSignal, self.passwordTextField.rac_textSignal, self.passwordAgainTextField.rac_textSignal] reduce:^(NSString *captha, NSString *password, NSString *passwordAgain){
        return @(captha.length == 6 && password.length > 0 && [password isEqualToString:passwordAgain]);
    }];
    
    
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
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)confirmButtonClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@""];
    
    NSDictionary *params = @{@"code": self.capthaTextField.text, @"newpwd": self.passwordTextField.text};
    [RegisterAPI forgotPasswordWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = dataDict[@"msg"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            hud.labelText = @"设置失败";
            hud.detailsLabelFont = dataDict[@"msg"];
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

- (IBAction)getCapthaButtonClicked:(id)sender {
    long nowTime = [[NSDate date]timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults]setObject:@(nowTime) forKey:@"LastTimeGetCapthaTime"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.getCapthaButton setEnabled:NO];
    timeCount = kDuration;
    [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"获取验证码中..."];
    
    NSDictionary *params = @{@"mobile": _currentPhone, @"type": @(1)};
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
@end
