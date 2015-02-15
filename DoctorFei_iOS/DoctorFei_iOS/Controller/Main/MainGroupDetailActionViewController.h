//
//  MainGroupDetailActionViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/19.
//
//

typedef NS_ENUM(NSUInteger, MainGroupDetailActionViewControllerMode) {
    MainGroupDetailActionViewControllerModeEdit,
    MainGroupDetailActionViewControllerModeSelect
};
#import <UIKit/UIKit.h>

@class Groups;
@class Friends;
@interface MainGroupDetailActionViewController : UIViewController

@property (nonatomic, assign) MainGroupDetailActionViewControllerMode vcMode;
@property (nonatomic, strong) Friends *selectedFriend;
@end
