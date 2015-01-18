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
#import <UIScrollView+EmptyDataSet.h>
@interface MyPageViewController ()
    <MyPageActionPopoverVCDelegate, WYPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *departAndJobLabel;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@end

@implementation MyPageViewController
{
    WYPopoverController *popoverController;
}
#pragma mark - LifeCycles
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
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - MyPageActionPopoverVC Delegate
- (void)newTalkButtonClickedWithMyPageActionPopoverViewController: (MyPageActionPopoverViewController *)vc {
    
}
- (void)newLogButtonClickedWithMyPageActionPopoverViewController: (MyPageActionPopoverViewController *)vc {
    
}

#pragma mark - UITableView Delegate

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark - DZNEmptyDataSrouce
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无内容"];
}

@end
