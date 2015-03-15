//
//  ContactPeronsalFriendDetailTableViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/15.
//
//


#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ContactPersonalFriendDetailMode) {
    ContactPersonalFriendDetailModeNormal,
    ContactPersonalFriendDetailModeMessage
};
@class Friends;

@interface ContactPeronsalFriendDetailTableViewController : UITableViewController

@property (nonatomic, strong) Friends *currentFriend;
@property (nonatomic, assign) ContactPersonalFriendDetailMode mode;
@end
