//
//  QuickReplyTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/13.
//
//

#import "QuickReplyTableViewController.h"

@interface QuickReplyTableViewController ()

- (IBAction)backButtonClicked:(id)sender;

@end

@implementation QuickReplyTableViewController

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
