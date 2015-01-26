//
//  ContactViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//
typedef enum ContactMode{
    ContactViewControllerModeNormal,
    ContactViewControllerModeGMAddFriend,
    ContactViewControllerModeCreateGroup,
    ContactViewControllerModeConsultation,
    ContactViewControllerModeTransfer
} ContactViewControllerMode;
#import <UIKit/UIKit.h>
typedef void (^ editCallback)(NSArray *friendSelected);
@interface ContactViewController : UIViewController
@property (nonatomic, assign) ContactViewControllerMode contactMode;
@property (nonatomic, copy) editCallback didSelectFriends;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end
