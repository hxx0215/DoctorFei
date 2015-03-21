//
//  MainChatTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/6.
//
//

#import "MainChatTableViewCell.h"
#import "Chat.h"
#import "Friends.h"
#import "Message.h"
#import <UIImageView+WebCache.h>
#import <JSBadgeView.h>
#import <NSDate+DateTools.h>
//#import "DataUtil.h"
@interface MainChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *situationLabel;
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
    if (_currentChat.type.intValue < 4) {
        Friends *friend = [[_currentChat.user allObjects]firstObject];
        if (friend.icon && friend.icon.length > 0) {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:friend.icon] placeholderImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
        }
        if (friend.noteName && friend.noteName.length > 0) {
            [self.nameLabel setText: friend.noteName];
        }
        else {
            [self.nameLabel setText: friend.realname];
        }
        [self.situationLabel setText:friend.situation];
    }
    else if (_currentChat.type.intValue == 4) {
        [self.avatarImageView setImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
        [self.nameLabel setText:_currentChat.title];
        [self.situationLabel setText:nil];
    }
    if ([_currentChat.unreadMessageCount intValue] > 0) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%d", _currentChat.unreadMessageCount.intValue];
    }
    else {
        self.badgeView.badgeText = @"";
    }
    Message *lastMessage = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"chat == %@", _currentChat] sortedBy:@"messageId" ascending:NO];
    if (lastMessage == nil) {
        [self.lastMessageLabel setText:@"没有消息记录"];
    }
    else if ([lastMessage.msgType isEqualToString:kSendMessageTypeText]) {
        [self.lastMessageLabel setText:lastMessage.content];
    }else if([lastMessage.msgType isEqualToString:kSendMessageTypeAudio]) {
        [self.lastMessageLabel setText:@"[语音]"];
    }else if ([lastMessage.msgType isEqualToString:kSendMessageTypeImage]) {
        [self.lastMessageLabel setText:@"[图片]"];
    }
    [self.durationLabel setText:lastMessage.createtime.timeAgoSinceNow];

}

@end
