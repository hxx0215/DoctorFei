//
//  ContactDoctorRankTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/12.
//
//

#import "ContactDoctorRankTableViewCell.h"
#import <UIImageView+WebCache.h>
@interface ContactDoctorRankTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *upCountLabel;

@end

@implementation ContactDoctorRankTableViewCell

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    [_nameLabel setText:_dataDict[@"realname"]];
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_dataDict[@"icon"]] placeholderImage:[UIImage imageNamed:@"doctor-ranking_preinstall_pic"]];
    [_addButton setEnabled:![_dataDict[@"myfriend"]intValue]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
