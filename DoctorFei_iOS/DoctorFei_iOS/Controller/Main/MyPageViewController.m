//
//  MyPageViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/15.
//
//

#import "MyPageViewController.h"
#import <WYPopoverController.h>
#import <WYStoryboardPopoverSegue.h>
#import "MyPageActionPopoverViewController.h"
@interface MyPageViewController ()
    <MyPageActionPopoverVCDelegate, WYPopoverControllerDelegate>
@end

@implementation MyPageViewController
{
    WYPopoverController *popoverController;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MyPageActionSegueIdentifier"]) {
        MyPageActionPopoverViewController *vc = [segue destinationViewController];
        vc.preferredContentSize = CGSizeMake(90, 101);
        vc.delegate = self;
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        
        popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        popoverController.delegate = self;
        popoverController.theme.outerCornerRadius = 0;
        popoverController.theme.innerCornerRadius = 0;
        popoverController.theme.fillTopColor = [UIColor darkGrayColor];
        popoverController.theme.fillBottomColor = [UIColor darkGrayColor];
        popoverController.theme.arrowHeight = 8.0f;
        popoverController.popoverLayoutMargins = UIEdgeInsetsZero;
        
    }
}

#pragma mark - MyPageActionPopoverVC Delegate
- (void)newTalkButtonClickedWithMyPageActionPopoverViewController: (MyPageActionPopoverViewController *)vc {
    
}
- (void)newLogButtonClickedWithMyPageActionPopoverViewController: (MyPageActionPopoverViewController *)vc {
    
}

@end
