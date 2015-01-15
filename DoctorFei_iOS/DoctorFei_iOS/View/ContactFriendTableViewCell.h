//
//  ContactFriendTableViewCell.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/3.
//
//

#import <UIKit/UIKit.h>
#import "ContactViewController.h"
@class Friends;

@interface ContactFriendTableViewCell : UITableViewCell

@property (nonatomic, strong) Friends *dataFriend;
@property (nonatomic, strong) NSDictionary *stableData;
@property (nonatomic, assign) ContactViewControllerMode contactMode;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@end
