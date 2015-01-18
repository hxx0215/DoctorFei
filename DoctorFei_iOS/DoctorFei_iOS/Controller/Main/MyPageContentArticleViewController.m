//
//  MyPageContentArticleViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentArticleViewController.h"

@interface MyPageContentArticleViewController ()

- (IBAction)confirmButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@end

@implementation MyPageContentArticleViewController

#pragma mark - Actions
- (IBAction)confirmButtonClicked:(id)sender {
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
