//
//  MyPageContentArticleViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentArticleViewController.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import <ReactiveCocoa.h>
#import "DayLog.h"
@interface MyPageContentArticleViewController ()

- (IBAction)confirmButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;

@end

@implementation MyPageContentArticleViewController
{
    MBProgressHUD *hud;
}
@synthesize currentDayLog = _currentDayLog;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.titleTextField.frame.size.height)];
    leftView.backgroundColor = self.titleTextField.backgroundColor;
    self.titleTextField.leftView = leftView;
    self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.contentTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 15, 15)];
    
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.titleTextField.rac_textSignal, [RACSignal merge:@[self.contentTextView.rac_textSignal, RACObserve(self.contentTextView, text)]]] reduce:^(NSString *title, NSString *content) {
        return @(title.length > 0 && content.length > 0);
    }];
    
    
    if (_currentDayLog) {
        self.title = @"修改日志";
        [_titleTextField setText:_currentDayLog.title];
        [_contentTextView setText:_currentDayLog.content];
    }else {
        self.title = @"写日志";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_titleTextField becomeFirstResponder];
}

-(void)setDoctorDaylog
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId
                             };
    NSDictionary *paramsBody = @{
                                 @"title": self.titleTextField.text,
                                 @"content": self.contentTextView.text
                                 };
    NSLog(@"%@",paramsBody);
    [DoctorAPI setDoctorDaylogWithParameters:params WithBodyParameters:paramsBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

-(void)updateDoctorDaylog
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"id" : _currentDayLog.dayLogId
                             };
    NSDictionary *paramsBody = @{
                                 @"title": self.titleTextField.text,
                                 @"content": self.contentTextView.text
                                 };
    [DoctorAPI updateDoctorDaylogWithParameters:params WithBodyParameters:paramsBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
- (IBAction)confirmButtonClicked:(id)sender {
    [_titleTextField resignFirstResponder];
    [_contentTextView resignFirstResponder];
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    if (!_currentDayLog) {
        hud.labelText = @"发表中...";
        [self setDoctorDaylog];
    } else {
        hud.labelText = @"修改中...";
        [self updateDoctorDaylog];
    }
}

- (IBAction)backButtonClicked:(id)sender {
    [_titleTextField resignFirstResponder];
    [_contentTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
