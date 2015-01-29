//
//  QuickReplyAddCustomViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/29.
//
//

#import "QuickReplyAddCustomViewController.h"
#import <MBProgressHUD.h>
#import <ReactiveCocoa.h>
#import "DoctorAPI.h"
@interface QuickReplyAddCustomViewController ()
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@end

@implementation QuickReplyAddCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.contentTextField.rac_textSignal] reduce:^(NSString *content){
        return @(content.length > 0);
    }];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.contentTextField.frame.size.height)];
    leftView.backgroundColor = self.contentTextField.backgroundColor;
    self.contentTextField.leftView = leftView;
    self.contentTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonClicked:(id)sender {
    NSNumber *currentId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    if (currentId) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.labelText = @"设置中";
        NSDictionary *param = @{
                                @"doctorid": currentId,
                                @"replymsg": _contentTextField.text
                                };
        [DoctorAPI setDoctorFastreplyWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dataDict = [responseObject firstObject];
            hud.mode = MBProgressHUDModeText;
            if ([dataDict[@"state"]intValue] == 1) {
                hud.labelText = @"设置成功";
                [hud hide:YES afterDelay:1.5f];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }else{
                hud.labelText = @"设置失败";
                hud.detailsLabelText = dataDict[@"msg"];
                [hud hide:YES afterDelay:1.5f];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"错误";
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.5f];
        }];
    }
}
@end
