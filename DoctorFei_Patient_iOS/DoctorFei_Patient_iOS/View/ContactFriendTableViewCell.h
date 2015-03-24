//
//  ContactFriendTableViewCell.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import <UIKit/UIKit.h>
@class Friends;

@interface ContactFriendTableViewCell : UITableViewCell

@property (nonatomic, strong) Friends *currentFriend;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@end
