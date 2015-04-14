//
//  ContactInviteTableViewCell.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/4/7.
//
//

#import <UIKit/UIKit.h>

@class RHPerson;

@interface ContactInviteTableViewCell : UITableViewCell

@property (nonatomic, strong) RHPerson *person;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;

@end
