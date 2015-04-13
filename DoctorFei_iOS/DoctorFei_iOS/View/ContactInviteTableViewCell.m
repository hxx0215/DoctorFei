//
//  ContactInviteTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/4/7.
//
//

#import "ContactInviteTableViewCell.h"
#import <RHPerson.h>
@interface ContactInviteTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation ContactInviteTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPerson:(RHPerson *)person {
    _person = person;
    if (_person.hasImage) {
        [_avatarImageView setImage:_person.thumbnail];
    }
    [_nameLabel setText:_person.name];
}

@end
