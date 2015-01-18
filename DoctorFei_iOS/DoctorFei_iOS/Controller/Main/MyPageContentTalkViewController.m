//
//  MyPageContentTalkViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentTalkViewController.h"

@interface MyPageContentTalkViewController ()

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *talkTextView;

@end

@implementation MyPageContentTalkViewController

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonClicked:(id)sender {
}
@end
