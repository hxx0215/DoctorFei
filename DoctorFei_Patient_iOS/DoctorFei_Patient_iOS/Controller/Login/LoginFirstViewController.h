//
//  LoginFirstViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by 刘向宏 on 15-1-22.
//
//

#import <UIKit/UIKit.h>
@class LoginFirstViewController;

@protocol RegisterTypeDelegate <NSObject>

- (void)userTypeButtonClickedWithUserType: (NSNumber *)userType;

@end


@interface LoginFirstViewController : UIViewController

@property (nonatomic, weak) id<RegisterTypeDelegate> delegate;

@end
