//
//  ContactMainViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/28.
//
//

#import <UIKit/UIKit.h>
typedef enum ContactMode{
    ContactMainViewControllerModeNormal,
    ContactMainViewControllerModeCreateGroup
}ContactMainViewControllerMode;
typedef void(^editCallback)(NSArray *friendSelect);
@interface ContactMainViewController : UIViewController
@property (nonatomic, assign)ContactMainViewControllerMode contactMode;
@property (nonatomic, copy)editCallback didSelectFriend;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end
