//
//  NotificationTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 4/17/15.
//
//

#import "NotificationTableViewCell.h"
@interface NotificationTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end
@implementation NotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backView.layer.cornerRadius = 4.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellData:(NSDictionary *)data{
    self.contentLabel.text = data[@"title"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[data[@"addtime"] doubleValue]];
    self.dateLabel.text = [formatter stringFromDate:date];
}
@end
