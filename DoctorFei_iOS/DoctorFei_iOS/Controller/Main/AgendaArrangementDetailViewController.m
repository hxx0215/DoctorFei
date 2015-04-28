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
#import "AgendaArrangement.h"
@interface AgendaArrangementDetailViewController ()
    <AgendaArrangementDetailEventVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;
@property (weak, nonatomic) IBOutlet UILabel *remindTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *remindTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
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
    BOOL isNew;
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
    if (_currentArrangement) {
        [self fetchDetailForArrangement];
        isNew = NO;
    }else{
        isNew = YES;
        _currentArrangement = [[AgendaArrangement alloc]init];
        _currentArrangement.allowTip = @1;
        _currentArrangement.tipType = @1;
    }
}

- (void)reloadUIView {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [_nameLabel setText:_currentArrangement.memberName];
    [_dataLabel setText:[formatter stringFromDate:_currentArrangement.dayTime]];
    [_timeLabel setText:[dateFormatter stringFromDate:_currentArrangement.dayTime]];
    [_eventLabel setText:_currentArrangement.title];
    if (_currentArrangement.allowTip.boolValue) {
        [_remindSwitch setOn:YES];
        [_remindTimeLabel setText:kRemindTimeArray[_currentArrangement.tipType.intValue - 1]];
    }else{
        [_remindSwitch setOn:NO];
    }
}
- (void)fetchDetailForArrangement {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"id": _currentArrangement.arrangeId,
                             @"doctorid": doctorId,
                             };
    [DoctorAPI getDoctorDayarrangeWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *result = [responseObject firstObject];
        if (result) {
            _currentArrangement.allowTip = @([result[@"allowtip"] intValue]);
            _currentArrangement.tipType = @([result[@"tiptype"] intValue]);
            _currentArrangement.tipTime = [NSDate dateWithTimeIntervalSince1970:[result[@"tiptime"] intValue]];
            _currentArrangement.note = result[@"note"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:NO];
                [self reloadUIView];
            });
        }
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"获取错误!";
        [hud hide:YES afterDelay:1.5f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
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
            _currentArrangement.memberId = currentSelectedFriend.userId;
            _currentArrangement.memberName = currentSelectedFriend.realname;
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
        _currentArrangement.dayTime = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
//        NSLog(@"%@", [NSDate dateWithTimeIntervalSince1970:dateTimeInterval]);
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
        _currentArrangement.dayTime = [NSDate dateWithTimeIntervalSince1970:dateTimeInterval];
//        NSLog(@"%@", [NSDate dateWithTimeIntervalSince1970:dateTimeInterval]);
    } cancelBlock:nil origin:sender];
    [actionSheetTimePicker showActionSheetPicker];
}

- (IBAction)remindTimeButtonClicked:(id)sender {
    ActionSheetStringPicker *actionSheetRemindTimePicker = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:kRemindTimeArray initialSelection:2 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        _currentArrangement.tipType = @(selectedIndex + 1);
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
    _currentArrangement.allowTip = @(_remindSwitch.on);
    if ([_eventLabel.text isEqualToString:@"无"]) {
        _currentArrangement.tipType = @0;
    }else {
        _currentArrangement.tipType = @([kRemindTimeArray indexOfObject:_remindTimeLabel.text] + 1);
    };
    
    if (_currentArrangement.memberName.length > 0
        && ![_dataLabel.text isEqualToString:@"点击选择日期"]
        && ![_timeLabel.text isEqualToString:@"点击选择时间"]
        && _eventLabel.text.length > 0) {
        [self addDayarrange];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"信息填写不全";
        [hud hide:YES afterDelay:1.5f];
    }
}

-(void)addDayarrange
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"添加中...";
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"id": isNew ? @0 : _currentArrangement.arrangeId,
                             @"title": _currentArrangement.title ? _currentArrangement.title : @"",
                             @"note": _currentArrangement.title ? _currentArrangement.title : @"",
//                             @"memberid": _currentArrangement.memberId,
                             @"membername": _currentArrangement.memberName,
                             @"daytime": @([_currentArrangement.dayTime timeIntervalSince1970]),
                             @"allowtip": _currentArrangement.allowTip,
                             @"tiptype": _currentArrangement.tipType
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
    _currentArrangement.title = eventString;
    [_eventLabel setText:eventString];
}
@end
