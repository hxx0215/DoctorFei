//
//  ForgetPasswordViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/23.
//
//

#import "ForgetPasswordViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "RegisterAPI.h"
#import "SetNewPasswordTableViewController.h"


static const NSTimeInterval kDuration = 60;

@interface ForgetPasswordViewController ()

- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *getCapthaButton;
- (IBAction)getCapthaButtonClicked:(id)sender;
@end

@implementation ForgetPasswordViewController
{
    NSTimer *countDownTimer;
    long timeCount;
    NSString *currentUserPhone;
}

- (void)viewWillAppear:(BOOL)animated {
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
    [self.phoneTextField resignFirstResponder];
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
    // Do any additional setup after loading the view.
    RAC(self.getCapthaButton, enabled) = [RACSignal combineLatest:@[self.phoneTextField.rac_textSignal] reduce:^(NSString *phone){
        return @(phone.length == 11 && timeCount == 0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GetCapthaSuccessSegueIdentifier"]) {
        SetNewPasswordTableViewController *vc = [segue destinationViewController];
        [vc setCurrentPhone:currentUserPhone];
    }
}

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)getCapthaButtonClicked:(id)sender {
    long nowTime = [[NSDate date]timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults]setObject:@(nowTime) forKey:@"LastTimeGetCapthaTime"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.getCapthaButton setEnabled:NO];
    timeCount = kDuration;
    [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    currentUserPhone = [self.phoneTextField.text copy];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"获取验证码中..."];

    NSDictionary *params = @{@"mobile": self.phoneTextField.text, @"type": @(1)};
    [RegisterAPI getCpathaWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"获取成功";
            hud.detailsLabelText = dataDict[@"msg"];
            [self performSegueWithIdentifier:@"GetCapthaSuccessSegueIdentifier" sender:nil];
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
