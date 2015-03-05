//
//  MainChatTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/26.
//
//

#import "MainChatTableViewCell.h"
#import "Chat.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
#import <JSBadgeView.h>
#import <NSDate+DateTools.h>

@interface MainChatTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) JSBadgeView *badgeView;

@end

@implementation MainChatTableViewCell
@synthesize currentChat = _currentChat;

- (void)awakeFromNib {
    // Initialization code
    self.badgeView = [[JSBadgeView alloc]initWithParentView:self.avatarImageView alignment:JSBadgeViewAlignmentTopRight];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentChat:(Chat *)currentChat {
    _currentChat = currentChat;
    Friends *friend = _currentChat.user;
    if (friend.icon && friend.icon.length > 0) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:friend.icon] placeholderImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
    }
    if ([_currentChat.unreadMessageCount intValue] > 0) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%d", _currentChat.unreadMessageCount.intValue];
    }
    else {
        self.badgeView.badgeText = @"";
    }
    if (friend.noteName && friend.noteName.length > 0) {
        [self.nameLabel setText: friend.noteName];
    }
    else {
        [self.nameLabel setText: friend.realname];
    }
    [self.lastMessageLabel setText:_currentChat.lastMessageContent];
    [self.durationLabel setText:_currentChat.lastMessageTime.timeAgoSinceNow];
}


@end
