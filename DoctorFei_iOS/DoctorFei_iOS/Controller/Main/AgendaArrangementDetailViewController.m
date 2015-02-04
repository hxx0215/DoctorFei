//
//  AgendaArrangementDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/15.
//
//

#import "AgendaArrangementDetailViewController.h"
#import <ActionSheetPicker.h>
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#define kRemindTimeArray @[@"日程时间", @"提前5分钟", @"提前15分钟", @"提前30分钟", @"提前1小时", @"提前2小时", @"提前1天", @"提前2天"]
#import "ContactViewController.h"
#import "Friends.h"
#import "DataUtil.h"
#import <ReactiveCocoa.h>
#import <NSDate+DateTools.h>
#import "AgendaArrangementDetailEventViewController.h"
@interface AgendaArrangementDetailViewController ()
    <AgendaArrangementDetailEventVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;
@property (weak, nonatomic) IBOutlet UILabel *remindTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *remindTimeButton;
- (IBAction)dateButtonClicked:(id)sender;
- (IBAction)timeButtonClicked:(id)sender;
- (IBAction)remindTimeButtonClicked:(id)sender;
- (IBAction)friendButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
@end

@implementation AgendaArrangementDetailViewController
{
    NSDate *date;
    double dateTimeInterval;
    Friends *currentSelectedFriend;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    RAC(self.remindTimeButton, enabled) = [RACSignal combineLatest:@[self.remindSwitch.rac_newOnChannel] reduce:^(NSNumber *isOn){
        if (!isOn.boolValue) {
            [_remindTimeLabel setText:@"无"];
        }else{
            [_remindTimeLabel setText:@"日程时间"];
        }
        return isOn;
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AgendaScheduleContactSelectSegueIdentifier"]) {
        UINavigationController *nav = [segue destinationViewController];
        ContactViewController *vc = nav.viewControllers[0];
        [vc setContactMode:ContactViewControllerModeScheduleSelectFriend];
        vc.didSelectFriends = ^(NSArray *selectArray){
            currentSelectedFriend = selectArray.firstObject;
            [_nameLabel setAttributedText:[DataUtil nameStringForFriend:currentSelectedFriend]];
        };
    } else if ([segue.identifier isEqualToString:@"AgendaScheduleEventSegueIdentifier"]) {
        AgendaArrangementDetailEventViewController *vc = [segue destinationViewController];
        [vc setDelegate:self];
    }
}

- (IBAction)dateButtonClicked:(id)sender {
    ActionSheetDatePicker *actionSheetDatePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        [_dataLabel setText:[formatter stringFromDate:selectedDate]];
        double time = ((NSDate *)selectedDate).timeIntervalSince1970;
        dateTimeInterval = (long)time - (long)time % 86400 + (long)dateTimeInterval % 86400;
        NSLog(@"%@", [NSDate dateWithTimeIntervalSince1970:dateTimeInterval]);
    } cancelBlock:nil origin:sender];
    [actionSheetDatePicker showActionSheetPicker];
}

- (IBAction)timeButtonClicked:(id)sender {
    ActionSheetDatePicker *actionSheetTimePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeTime selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        [_timeLabel setText:[dateFormatter stringFromDate:selectedDate]];
        double time = ((NSDate *)selectedDate).timeIntervalSince1970;
        dateTimeInterval = (long)dateTimeInterval - (long)dateTimeInterval % 86400 + (long)time % 86400;
        NSLog(@"%@", [NSDate dateWithTimeIntervalSince1970:dateTimeInterval]);
    } cancelBlock:nil origin:sender];
    [actionSheetTimePicker showActionSheetPicker];
}

- (IBAction)remindTimeButtonClicked:(id)sender {
    ActionSheetStringPicker *actionSheetRemindTimePicker = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:kRemindTimeArray initialSelection:2 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [_remindTimeLabel setText:selectedValue];
    } cancelBlock:nil origin:sender];
    [actionSheetRemindTimePicker showActionSheetPicker];
}

- (IBAction)friendButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"AgendaScheduleContactSelectSegueIdentifier" sender:nil];
}


- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)OKButtonClicked:(id)sender {
    [self addDayarrange];
}

-(void)addDayarrange
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"添加中";
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSNumber *tiptype;
    if ([_eventLabel.text isEqualToString:@"无"]) {
        tiptype = @0;
    }else {
        tiptype = @([kRemindTimeArray indexOfObject:_remindTimeLabel.text] + 1);
    };
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"title": _eventLabel.text,
                             @"note": _eventLabel.text,
                             @"memberid": currentSelectedFriend.userId,
                             @"membername": currentSelectedFriend.realname,
                             @"daytime": @(dateTimeInterval),
                             @"allowtip": @(_remindSwitch.on),
                             @"tiptype": tiptype
                             };
    NSLog(@"%@",params);
    [DoctorAPI setDoctorDayarrangeWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dic[@"msg"];
        if(dic[@"state"]>0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - AgendaArrangementDetailEventVCDelegate
- (void)confirmButtonClickedForAgendaArrangementDetailEventVC:(AgendaArrangementDetailEventViewController *)vc eventString:(NSString *)eventString {
    [_eventLabel setText:eventString];
}
@end
