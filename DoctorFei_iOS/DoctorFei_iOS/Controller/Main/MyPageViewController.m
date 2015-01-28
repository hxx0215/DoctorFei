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
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import "MyPageContentArticleTableViewCell.h"
#import "MyPageContentTalkTableViewCell.h"
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
    NSArray *shuoshuoArray;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadAllShuoshuoAndDaylog];
}

-(void)loadAllShuoshuoAndDaylog
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [DoctorAPI DoctorShuoshuoWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        shuoshuoArray = [responseObject copy];
        [self.contentTableView reloadData];
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
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
        popoverController.dismissOnTap = YES;
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
    [self performSegueWithIdentifier:@"MyPageContentTalkSegueIdentifier" sender:nil];
}
- (void)newLogButtonClickedWithMyPageActionPopoverViewController: (MyPageActionPopoverViewController *)vc {
    [self performSegueWithIdentifier:@"MyPageContentArticleSegueIdentifier" sender:nil];
}

#pragma mark - UITableView Delegate

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [shuoshuoArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyPageContentTalkTableViewCellIdentifier = @"MyPageContentTalkTableViewCellIdentifier";
    static NSString *MyPageContentArticleTableViewCellIdentifier = @"MyPageContentArticleTableViewCell";
    NSDictionary *dic =[shuoshuoArray objectAtIndex:indexPath.row];
    if([dic[@"type"] integerValue] == 1)
    {
        MyPageContentArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyPageContentTalkTableViewCellIdentifier forIndexPath:indexPath];
        [cell setCurrentDic:dic];
        return cell;
    }
    else
    {
        MyPageContentArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyPageContentArticleTableViewCellIdentifier forIndexPath:indexPath];
        [cell setCurrentDic:dic];
        return cell;
    }
}


#pragma mark - DZNEmptyDataSrouce
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无内容"];
}

@end
