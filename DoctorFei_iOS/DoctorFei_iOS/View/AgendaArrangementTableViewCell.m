//
//  TimeScheduleTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/14.
//
//

#import "AgendaArrangementTableViewCell.h"
#import "AgendaArrangement.h"

@interface AgendaArrangementTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;

@end

@implementation AgendaArrangementTableViewCell
@synthesize arrangement = _arrangement;

- (void)setArrangement:(AgendaArrangement *)arrangement {
    _arrangement = arrangement;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    [_dateLabel setText:[formatter stringFromDate:_arrangement.dayTime]];
    [_titleLabel setText:_arrangement.title];
    [_memberNameLabel setText:_arrangement.memberName];
}

@end
