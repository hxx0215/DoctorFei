//
//  MyPageActionPopoverViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/15.
//
//

#import "MyPageActionPopoverViewController.h"

@interface MyPageActionPopoverViewController ()

- (IBAction)newTalkButtonClicked:(id)sender;
- (IBAction)newLogButtonClicked:(id)sender;

@end

@implementation MyPageActionPopoverViewController
@synthesize delegate = _delegate;
- (IBAction)newTalkButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(newTalkButtonClickedWithMyPageActionPopoverViewController:)]) {
        [_delegate newTalkButtonClickedWithMyPageActionPopoverViewController:self];
    }
}

- (IBAction)newLogButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(newLogButtonClickedWithMyPageActionPopoverViewController:)]) {
        [_delegate newLogButtonClickedWithMyPageActionPopoverViewController:self];
    }
}
@end
