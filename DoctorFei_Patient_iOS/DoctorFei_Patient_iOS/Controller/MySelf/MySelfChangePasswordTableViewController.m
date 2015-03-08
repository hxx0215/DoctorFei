//
//  MySelfChangePasswordTableViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import "MySelfChangePasswordTableViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "MemberAPI.h"
@interface MySelfChangePasswordTableViewController ()

- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *originalPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *setPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
- (IBAction)confirmButtonClicked:(id)sender;
@end

@implementation MySelfChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.originalPasswordTextField.rac_textSignal, self.setPasswordTextField.rac_textSignal, self.repeatPasswordTextField.rac_textSignal] reduce:^(NSString *original, NSString *set, NSString *repeat) {
        return @(original.length > 0 && set.length > 0 && [set isEqualToString:repeat]);
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

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)confirmButtonClicked:(id)sender {
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"oldpwd": _originalPasswordTextField.text,
                            @"newpwd": _setPasswordTextField.text
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [MemberAPI modifyPwdWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *result = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = result[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([result[@"state"] intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
@end
