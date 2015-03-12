//
//  ContactAddByTelViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/12.
//
//

#import "ContactAddByTelViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "UserAPI.h"
#import "MemberAPI.h"
@interface ContactAddByTelViewController ()
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@end

@implementation ContactAddByTelViewController
{
    MBProgressHUD *hud;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[_telTextField.rac_textSignal] reduce:^(NSString *info){
        return @(info.length > 0);
    }];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.telTextField.frame.size.height)];
    leftView.backgroundColor = self.telTextField.backgroundColor;
    self.telTextField.leftView = leftView;
    self.telTextField.leftViewMode = UITextFieldViewModeAlways;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.telTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.telTextField resignFirstResponder];
}

- (void)searchUserWithPhoneText:(NSString *)phone {
    NSDictionary *param = @{@"mobile": phone};
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [UserAPI searchUserWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *dataArray = (NSArray *)responseObject;
        if (dataArray.count > 0) {
            [self setFriendWithDataArray:dataArray];
        }else{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"没有该用户!";
            [hud hide:YES afterDelay:1.0f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (void)setFriendWithDataArray:(NSArray *)dataArray {
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    for (NSDictionary *dict in dataArray) {
        NSDictionary *param = @{
                                @"userid": memberId,
                                @"friendid": dict[@"userid"],
                                @"usertype": dict[@"usertype"]
                                };
        [MemberAPI setFriendWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dic = [responseObject firstObject];
            if ([dic[@"state"] integerValue]==1) {
                UIImageView *completeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_prompt-01_pic.png"]];
                hud.mode = MBProgressHUDModeCustomView;
                hud.dimBackground = YES;
                hud.customView = completeImage;
            }else{
                hud.mode = MBProgressHUDModeText;
            }
            hud.detailsLabelText = dic[@"msg"];//NSLocalizedString(@"好友添加成功", nil);
            [hud hide:YES afterDelay:1.0f];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"错误";
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.5f];
        }];

    }
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
    [self searchUserWithPhoneText:_telTextField.text];
}
@end
