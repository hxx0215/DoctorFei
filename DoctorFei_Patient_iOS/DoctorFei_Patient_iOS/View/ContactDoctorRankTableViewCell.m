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
@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation ContactDoctorRankTableViewCell

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    [_nameLabel setText:_dataDict[@"realname"]];
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_dataDict[@"icon"]] placeholderImage:[UIImage imageNamed:@"doctor-ranking_preinstall_pic"]];
    [_addButton setEnabled:![_dataDict[@"myfriend"]intValue]];
    self.hospitalLabel.text = [NSString stringWithFormat:@"%@ %@",_dataDict[@"hospital"],_dataDict[@"jobtitle"] ];
    self.goodAtLabel.text = _dataDict[@"department"];
    self.upCountLabel.text = [NSString stringWithFormat:@"赞 %@",[_dataDict[@"zan"] stringValue]];
}

- (void)awakeFromNib {
    // Initialization code
    _backView.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
