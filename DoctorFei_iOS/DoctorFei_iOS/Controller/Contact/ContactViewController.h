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
    ContactViewControllerModeCreateGroup
} ContactViewControllerMode;
#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController
@property (nonatomic, assign) ContactViewControllerMode contactMode;
@end
