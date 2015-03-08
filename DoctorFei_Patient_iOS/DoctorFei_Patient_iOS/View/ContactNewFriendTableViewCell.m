//
//  ContactNewFriendTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/8.
//
//

#import "ContactNewFriendTableViewCell.h"
#import <UIImageView+WebCache.h>
@interface ContactNewFriendTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreedLabel;


@end

@implementation ContactNewFriendTableViewCell
@synthesize dataDict = _dataDict;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    if ([_dataDict[@"icon"] length]> 0) {
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_dataDict[@"icon"]] placeholderImage:[UIImage imageNamed:@"list_user_preinstall_pic"]];
    }else {
        [_avatarImageView setImage:[UIImage imageNamed:@"list_user_preinstall_pic"]];
    }
    if ([_dataDict[@"RealName"]length] > 0) {
        [_nameLabel setText:_dataDict[@"RealName"]];
    } else {
        [_nameLabel setText:_dataDict[@"UserName"]];
    }
    NSNumber *isAudit = _dataDict[@"isaudit"];
    if (isAudit.intValue == 0) {
        [self.agreedLabel setHidden:YES];
        [self.agreeButton setHidden:NO];
    }else{
        [self.agreedLabel setHidden:NO];
        [self.agreeButton setHidden:YES];
        if (isAudit.intValue == 1) {
            [self.agreedLabel setText:@"已同意"];
        }else if (isAudit.intValue == 2) {
            [self.agreedLabel setText:@"不同意"];
        }else{
            [self.agreedLabel setText:@"取消"];
        }
    }
}
@end
