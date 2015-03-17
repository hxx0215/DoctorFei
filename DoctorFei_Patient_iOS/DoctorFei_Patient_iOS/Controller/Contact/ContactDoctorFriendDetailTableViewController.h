//
//  ContactDoctorFriendDetailTableViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/15.
//
//

typedef NS_ENUM(NSUInteger, ContactDoctorFriendDetailMode) {
    ContactDoctorFriendDetailModeNormal,
    ContactDoctorFriendDetailModeMessage
};

#import <UIKit/UIKit.h>

@class Friends;

@interface ContactDoctorFriendDetailTableViewController : UITableViewController

@property (nonatomic, strong) Friends *currentFriend;
@property (nonatomic, assign) ContactDoctorFriendDetailMode mode;

@end

