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

@interface MyPageContentArticleViewController ()

- (IBAction)confirmButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@end

@implementation MyPageContentArticleViewController
{
    MBProgressHUD *hud;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    //self.contentTextView.text = @"";
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
                             @"id" : @"123"
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5];
    }];
}

#pragma mark - Actions
- (IBAction)confirmButtonClicked:(id)sender {
    //调试发表医生日志
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"发表中...";
    BOOL isNew = YES;
    if(isNew)
    {
        [self setDoctorDaylog];
    }
    else
    {
        [self updateDoctorDaylog];
    }
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
