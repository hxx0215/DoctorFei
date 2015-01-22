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

@interface MainGroupDetailActionViewController : UIViewController

@property (nonatomic, assign) MainGroupDetailActionViewControllerMode vcMode;

@end
