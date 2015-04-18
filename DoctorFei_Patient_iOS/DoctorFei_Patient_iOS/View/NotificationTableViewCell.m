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

@end
@implementation NotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellData:(NSDictionary *)data{
    self.contentLabel.text = data[@"title"];
}
@end
