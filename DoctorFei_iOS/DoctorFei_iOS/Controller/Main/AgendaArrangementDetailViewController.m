//
//  AgendaArrangementDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/15.
//
//

#import "AgendaArrangementDetailViewController.h"
#import <ActionSheetPicker.h>
#define kRemindTimeArray @[@"提前1小时", @"提前2小时", @"提前3小时", @"提前6小时", @"提前一天"]
@interface AgendaArrangementDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;
@property (weak, nonatomic) IBOutlet UILabel *remindTimeLabel;
- (IBAction)dateButtonClicked:(id)sender;
- (IBAction)timeButtonClicked:(id)sender;
- (IBAction)remindTimeButtonClicked:(id)sender;


- (IBAction)backButtonClicked:(id)sender;
@end

@implementation AgendaArrangementDetailViewController

- (IBAction)dateButtonClicked:(id)sender {
    ActionSheetDatePicker *actionSheetDatePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        [_dataLabel setText:[selectedDate description]];
    } cancelBlock:nil origin:sender];
    [actionSheetDatePicker showActionSheetPicker];
}

- (IBAction)timeButtonClicked:(id)sender {
    ActionSheetDatePicker *actionSheetTimePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeTime selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
        [_timeLabel setText:[dateFormatter stringFromDate:selectedDate]];
    } cancelBlock:nil origin:sender];
    [actionSheetTimePicker showActionSheetPicker];
}

- (IBAction)remindTimeButtonClicked:(id)sender {
    ActionSheetStringPicker *actionSheetRemindTimePicker = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:kRemindTimeArray initialSelection:2 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [_remindTimeLabel setText:selectedValue];
    } cancelBlock:nil origin:sender];
    [actionSheetRemindTimePicker showActionSheetPicker];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
