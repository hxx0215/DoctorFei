//
//  MoreFeedbackViewController.m
//  DoctorFei_iOS
//
//  Created by 刘向宏 on 14-12-4.
//
//

#import "MoreFeedbackViewController.h"
#import <ReactiveCocoa.h>
//#import <IHKeyboardAvoiding.h>
#import "UserAPI.h"
#import <MBProgressHUD.h>
@interface MoreFeedbackViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
@property (strong, nonatomic) IBOutlet UITextView *feedbackContent;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewToBottom;
@property (assign, nonatomic) CGRect feedbackOriginFrame;
@end

@implementation MoreFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.feedbackContent.layer.borderWidth = 1.0;
    self.feedbackContent.layer.borderColor = UIColorFromRGB(0xA6A6A6).CGColor;
    self.feedbackContent.layer.cornerRadius = 10.0;
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.feedbackContent.rac_textSignal] reduce:^(NSString *string){
        return @(string.length > 0);
    }];
    
//    [IHKeyboardAvoiding setAvoidingView:self.feedbackContent withTarget:self.feedbackContent];
//    
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sendButtonClicked:(id)sender {
    [self.feedbackContent resignFirstResponder];
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorId,
                            @"type": @(0),
                            @"feedback" : self.feedbackContent.text
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"提交反馈中...";
    [UserAPI setFeedBackWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        hud.mode = MBProgressHUDModeText;
        NSDictionary *dict = [responseObject firstObject];
        if ([dict[@"state"]intValue] == 1) {
            hud.labelText = dict[@"msg"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            hud.labelText = @"提交错误";
            hud.detailsLabelText = dict[@"msg"];
        }
        [hud hide:YES afterDelay:1.5f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.feedbackOriginFrame = self.feedbackContent.frame;
    [self.feedbackContent becomeFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    CGRect rect = textView.frame;
//    rect.size.height = self.feedbackOriginFrame.size.height - 156;
//    textView.frame = rect;
    self.textViewToBottom.constant = 60 + 200;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    self.textViewToBottom.constant = 60;
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
