//
//  ContactFriendTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
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
@synthesize currentFriend = _currentFriend;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentFriend:(Friends *)currentFriend {
    _currentFriend = currentFriend;
    if (_currentFriend.icon.length > 0){
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_currentFriend.icon] placeholderImage:[UIImage imageNamed:@"list_user-small_example_pic"]];
    }else{
        [self.avatarImageView setImage:[UIImage imageNamed:@"list_user-small_example_pic"]];
    }
    [self.nameLabel setAttributedText:[DataUtil nameStringForFriend:_currentFriend]];
}
- (void)layoutSubviews{
    [super layoutSubviews];
}

@end
