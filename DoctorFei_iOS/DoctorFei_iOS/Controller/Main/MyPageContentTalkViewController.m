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

@interface MyPageContentTalkViewController ()

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *talkTextView;

@end

@implementation MyPageContentTalkViewController
{
    MBProgressHUD *hud;
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

-(void)updateDoctorShuoshuo
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"id" : @"123"
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
    //调试发表医生日志
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"发表中...";
    BOOL isNew = YES;
    if(isNew)
    {
        [self setDoctorShuoshuo];
    }
    else
    {
        [self updateDoctorShuoshuo];
    }
}
@end
