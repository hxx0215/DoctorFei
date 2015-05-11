//
//  ContactGroupListTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/1.
//
//

#import "ContactGroupListTableViewCell.h"
#import "GroupChat.h"
#import <UIImageView+WebCache.h>
@interface ContactGroupListTableViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@end


@implementation ContactGroupListTableViewCell

- (void)setCurrentGroupChat:(GroupChat *)currentGroupChat {
    _currentGroupChat = currentGroupChat;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_currentGroupChat.icon] placeholderImage:[UIImage imageNamed:@"group_preinstall_pic"]];
    [_nameLabel setText:[NSString stringWithFormat:@"%@(%@)",_currentGroupChat.name, _currentGroupChat.total.stringValue]];
    [_typeButton setHighlighted:!_currentGroupChat.flag.boolValue];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end
