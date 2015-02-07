//
//  MainGroupPopoverViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import <UIKit/UIKit.h>

@class MainGroupPopoverViewController;
@class Groups;
@protocol MainGroupPopoverVCDelegate <NSObject>

- (void)editButtonClickedForPopoverVC:(MainGroupPopoverViewController *)vc;
- (void)groupCellSelectedForPopoverVC:(MainGroupPopoverViewController *)vc withGroup:(Groups *)group;
@end

@interface MainGroupPopoverViewController : UIViewController

@property (nonatomic, weak) id<MainGroupPopoverVCDelegate> delegate;

@end
