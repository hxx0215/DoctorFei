//
//  LoginViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "LoginViewController.h"
#import <IHKeyboardAvoiding.h>
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "DeviceUtil.h"
#import "MemberAPI.h"
#import "APService.h"
#import "DataUtil.h"
//#import "SocketConnection.h"
@interface LoginViewController ()
    <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *loginBackgroundView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *autoLoginButton;
- (IBAction)autoLoginButtonClicked:(id)sender;
- (IBAction)demoButtonClicked:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [IHKeyboardAvoiding setAvoidingView:self.loginBackgroundView];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.phoneTextField.frame.size.height)];
    leftView.backgroundColor = self.phoneTextField.backgroundColor;
    self.phoneTextField.leftView = leftView;
    self.phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.passwordTextField.frame.size.height)];
    leftView1.backgroundColor = self.passwordTextField.backgroundColor;
    self.passwordTextField.leftView = leftView1;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[self.phoneTextField.rac_textSignal, self.passwordTextField.rac_textSignal] reduce:^(NSString *phone, NSString *password){
        return @(phone.length == 11 && password.length > 0);
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *autoLoginUserName = [defaults objectForKey:@"autoLoginUserName"] ? [defaults objectForKey:@"autoLoginUserName"]: @"";
    NSString *autoLoginPassword = [defaults objectForKey:@"autoLoginPassword"] ? [defaults objectForKey:@"autoLoginPassword"]: @"";
    BOOL autoLogin = [[defaults objectForKey:@"IsAutoLogin"] boolValue];
    self.autoLoginButton.selected = autoLogin;
    self.loginButton.enabled = autoLogin;
    if (!autoLoginPassword || !autoLoginUserName){
        [defaults setObject:@"" forKey:@"autoLoginUserName"];
        [defaults setObject:@"" forKey:@"autoLoginPassword"];
        [defaults synchronize];
    }
//    else
//    {
//        self.loginButton.enabled = YES;
//    }
    self.phoneTextField.text = self.autoLoginButton.selected ? autoLoginUserName :@"";
    self.passwordTextField.text = self.autoLoginButton.selected ? autoLoginPassword :@"";

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.phoneTextField becomeFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.passwordTextField becomeFirstResponder];
    [self.passwordTextField resignFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.phoneTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"LoginRegisterSegueIdentifier"]) {
        [self.phoneTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
    }
}

#pragma mark - Actions
- (IBAction)loginButtonClicked:(id)sender {

//    NSLog(@"%@",[APService registrationID]);
    if (self.autoLoginButton.selected)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.phoneTextField.text forKey:@"autoLoginUserName"];
        [defaults setObject:self.passwordTextField.text forKey:@"autoLoginPassword"];
        [defaults synchronize];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"登录中..."];
    NSDictionary *params = @{
                             @"username": self.phoneTextField.text,
                             @"password": self.passwordTextField.text,
                             @"sn": [DeviceUtil getUUID]
                             };
    NSLog(@"%@",params);
    [MemberAPI loginWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
//            hud.labelText = dataDict[@"msg"];
            [hud hide:YES];
            NSNumber *lastLoginUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastLoginUserId"];
            if ([lastLoginUserId intValue] != [dataDict[@"userId"]intValue]) {
                [DataUtil cleanCoreData];
            }
            if ([self.autoLoginButton isSelected]) {
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"IsAutoLogin"];
            }
            else{
                [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"IsAutoLogin"];
            }
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"userId"] forKey:@"UserId"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"userId"] forKey:@"LastLoginUserId"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"icon"] forKey:@"UserIcon"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"RealName"] forKey:@"UserRealName"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"hospital"] forKey:@"UserHospital"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"department"] forKey:@"UserDepartment"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"jobtitle"] forKey:@"UserJobTitle"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"Email"] forKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"OtherContact"] forKey:@"UserOtherContact"];
            [[NSUserDefaults standardUserDefaults] synchronize];
//            [[SocketConnection sharedConnection]beginListen];
//            [[SocketConnection sharedConnection]sendCheckMessages];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            hud.labelText = @"登录错误";
            hud.detailsLabelText = dataDict[@"msg"];
            [hud hide:YES afterDelay:1.5f];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
    
//    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)autoLoginButtonClicked:(id)sender {
    if ([self.autoLoginButton isSelected]) {
        [self.autoLoginButton setSelected:NO];
    }
    else{
        [self.autoLoginButton setSelected:YES];
    }
}

- (IBAction)demoButtonClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"UserId"];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.phoneTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    return YES;
}
@end
