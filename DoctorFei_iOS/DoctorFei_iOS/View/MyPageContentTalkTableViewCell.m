//
//  MyPageContentTalkTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentTalkTableViewCell.h"

#import "ShuoShuo.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
#import <NSDate+DateTools.h>
@interface MyPageContentTalkTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end

@implementation MyPageContentTalkTableViewCell

- (void)setShuoshuo:(ShuoShuo *)shuoshuo {
    _shuoshuo = shuoshuo;
    [_nameLabel setText:@"无姓名"];
    [_avatarImageView setImage:[UIImage imageNamed:@"home_user_example_pic"]];
    if (_shuoshuo.doctorId) {
        NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
        if (_shuoshuo.doctorId.intValue == userId.intValue) {
            _editButton.hidden = NO;
            _deleteButton.hidden = NO;
            [_nameLabel setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"]];
            NSString *icon = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserIcon"];
            if (icon && icon.length > 0) {
                [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"home_user_example_pic"]];
            }
            else {
                [_avatarImageView setImage:[UIImage imageNamed:@"home_user_example_pic"]];
            }
        } else {
            _editButton.hidden = YES;
            _deleteButton.hidden = YES;
            Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:_shuoshuo.doctorId];
            if (friend) {
                [_nameLabel setText:friend.realname];
                if (friend.icon.length) {
                    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:friend.icon] placeholderImage:[UIImage imageNamed:@"home_user_example_pic"]];
                }
            }
        }
    }
    [_contentLabel setText:_shuoshuo.content];
    [_timeLabel setText:_shuoshuo.createTime.timeAgoSinceNow];

}

@end
