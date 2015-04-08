//
//  MyPageContentArticleDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentArticleDetailViewController.h"
#import "DayLog.h"
#import <NSDate+DateTools.h>
#import "MyPageContentArticleViewController.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>

@interface MyPageContentArticleDetailViewController ()
    <UIAlertViewDelegate>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
- (IBAction)deleteButtonClicked:(id)sender;
- (IBAction)repostButtonClicked:(id)sender;

@end

@implementation MyPageContentArticleDetailViewController
@synthesize currentDayLog = _currentDayLog;


- (void)viewDidLoad {
    [super viewDidLoad];
    [_contentTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 15, 15)];
    if (_currentDayLog) {
        [_titleLabel setText:_currentDayLog.title];
        [_createTimeLabel setText:_currentDayLog.createTime.timeAgoSinceNow];
        [_contentTextView setText:_currentDayLog.content];
        NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
        if (_currentDayLog.doctorId && userId && _currentDayLog.doctorId.intValue == userId.intValue) {
            _deleteButton.hidden = NO;
            _repostButton.hidden = YES;
        }else{
            _deleteButton.hidden = YES;
            _repostButton.hidden = NO;
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    NSDictionary *param = @{
                            @"doctorid": _currentDayLog.doctorId,
                            @"id": _currentDayLog.dayLogId
                            };
    [DoctorAPI getDoctorDaylogWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            NSDictionary *dict = ((NSArray *)responseObject).firstObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",dict[@"title"]);
                if ([dict[@"title"]isKindOfClass:[NSString class]]) {
                    [_titleLabel setText:dict[@"title"]];
                }
                [_contentTextView setText:dict[@"content"]];
                NSDate *createTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"createtime"]intValue]];
                [_createTimeLabel setText:createTime.timeAgoSinceNow];
            });
        }
        [hud hide:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.0f];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MyPageContentEditArticleSegueIdentifier"]) {
        UINavigationController *nav = [segue destinationViewController];
        MyPageContentArticleViewController *vc = nav.viewControllers[0];
        [vc setCurrentDayLog:_currentDayLog];
    }
}

- (void)deleteDaylogByDaylog:(DayLog *)daylog {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"删除日志中...";
    NSDictionary *delparams = @{
                                @"doctorid": daylog.doctorId,
                                @"id" : daylog.dayLogId,
                                @"type" : @2 //1为说说 2为日志
                                };
    [DoctorAPI delDoctorShuoshuoOrDaylogWithParameters:delparams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dic[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.0f];
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)deleteButtonClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认删除这篇日志吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (IBAction)repostButtonClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"转载日志中...";
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": userId,
                            @"id": _currentDayLog.dayLogId
                            };
    [DoctorAPI setDoctorDayZZWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dic[@"msg"];
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.0f];
    }];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self deleteDaylogByDaylog:_currentDayLog];
    }
}
@end
