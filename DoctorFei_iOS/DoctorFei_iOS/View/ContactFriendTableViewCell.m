//
//  ContactFriendTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/3.
//
//

#import "ContactFriendTableViewCell.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
#import "DataUtil.h"
@interface ContactFriendTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ContactFriendTableViewCell
@synthesize dataFriend = _dataFriend;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setStableData:(NSDictionary *)stableData{
    self.avatarImageView.image = [UIImage imageNamed:stableData[@"icon"]];
    self.nameLabel.text = stableData[@"RealName"];
}
- (void)setDataFriend:(Friends *)dataFriend {
    _dataFriend = dataFriend;
    if (_dataFriend.icon != nil && _dataFriend.icon.length > 0) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_dataFriend.icon] placeholderImage:[UIImage imageNamed:@"list_user-small_example_pic"]];
    }
    else{
        [self.avatarImageView setImage:[UIImage imageNamed:@"list_user-small_example_pic"]];
    }
    [self.nameLabel setAttributedText:[DataUtil nameStringForFriend:_dataFriend]];
//    if (_dataFriend.noteName && _dataFriend.noteName.length > 0) {
//        NSString *nameString = [NSString stringWithFormat:@"%@(%@)",_dataFriend.noteName, _dataFriend.realname];
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:nameString];
//        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xAAAAAA) range:NSMakeRange(_dataFriend.noteName.length, _dataFriend.realname.length + 2)];
//        [self.nameLabel setAttributedText:attributedString];
////        [self.nameLabel setText:_dataFriend.noteName];
//    }
//    else{
//        [self.nameLabel setText:_dataFriend.realname];
//    }
}
@end
