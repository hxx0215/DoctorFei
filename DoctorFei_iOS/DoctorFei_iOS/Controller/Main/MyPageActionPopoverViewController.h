//
//  MyPageActionPopoverViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/15.
//
//

#import <UIKit/UIKit.h>

@class MyPageActionPopoverViewController;

@protocol MyPageActionPopoverVCDelegate <NSObject>

- (void)newTalkButtonClickedWithMyPageActionPopoverViewController: (MyPageActionPopoverViewController *)vc;
- (void)newLogButtonClickedWithMyPageActionPopoverViewController: (MyPageActionPopoverViewController *)vc;

@end

@interface MyPageActionPopoverViewController : UIViewController

@property (nonatomic, weak) id<MyPageActionPopoverVCDelegate> delegate;

@end
