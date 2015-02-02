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

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)deleteButtonClicked:(id)sender {
    //TODO
}

- (IBAction)repostButtonClicked:(id)sender {
}
@end
