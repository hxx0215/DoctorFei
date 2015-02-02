//
//  MyPageContentTalkViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentTalkViewController.h"
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
#import <ReactiveCocoa.h>
#import "ShuoShuo.h"
@interface MyPageContentTalkViewController ()

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *talkTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;

@end

@implementation MyPageContentTalkViewController
{
    MBProgressHUD *hud;
}
@synthesize currentShuoShuo = _currentShuoShuo;

- (void)viewDidLoad {
    [super viewDidLoad];
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.talkTextView.rac_textSignal] reduce:^(NSString *text){
        return @(text.length > 0);
    }];
    [self.talkTextView setTextContainerInset:UIEdgeInsetsMake(20, 20, 20, 20)];
    if (_currentShuoShuo) {
        self.title = @"修改说说";
        [_talkTextView setText:_currentShuoShuo.content];
    }else{
        self.title = @"发说说";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.talkTextView becomeFirstResponder];
}
-(void)setDoctorShuoshuo
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId
                             };
    NSDictionary *paramsBody = @{
                                 @"content": self.talkTextView.text
                                 };
    NSLog(@"%@",paramsBody);
    [DoctorAPI setDoctorShuoshuoWithParameters:params WithBodyParameters:paramsBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dic[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5];
    }];
}

-(void)updateDoctorShuoshuo
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"id" : _currentShuoShuo.shuoshuoId
                             };
    NSDictionary *paramsBody = @{
                                 @"content": self.talkTextView.text
                                 };
    [DoctorAPI updateDoctorShuoshuoWithParameters:params WithBodyParameters:paramsBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        NSLog(@"%@",dic[@"msg"]);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dic[@"msg"];
        [hud hide:YES afterDelay:1.5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5];
    }];
}
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonClicked:(id)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    if (_currentShuoShuo) {
        hud.labelText = @"修改中...";
        [self updateDoctorShuoshuo];
    } else {
        hud.labelText = @"发表中...";
        [self setDoctorShuoshuo];
    }
}
@end
