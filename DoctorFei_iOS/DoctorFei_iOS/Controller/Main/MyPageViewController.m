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
#import "ShuoShuo.h"
#import "DayLog.h"
#import <UIImageView+WebCache.h>
#import "Friends.h"
#import "MyPageContentTalkViewController.h"
#import "MyPageContentArticleDetailViewController.h"
@interface MyPageViewController ()
    <MyPageActionPopoverVCDelegate, WYPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIAlertViewDelegate>
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)contentTypeChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *departAndJobLabel;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *contentTypeSegmentControl;
@end

@implementation MyPageViewController
{
    WYPopoverController *popoverController;
    NSMutableArray *myContentArray, *repostContentArray;
    NSInteger currentIndexPathRow;
}
@synthesize currentDoctorId = _currentDoctorId;


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAllShuoshuoAndDaylog];
    //设置表头信息
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    if (userId.intValue == _currentDoctorId.intValue) {
        [self setMyInfoView];
    } else{
        self.navigationItem.rightBarButtonItem = nil;
        Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:_currentDoctorId];
        if (friend) {
            [_nameLabel setText:friend.realname];
            //TODO nickName; 采用Category通用解决
            if (friend.icon.length) {
                [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:friend.icon] placeholderImage:[UIImage imageNamed:@"home_user_example_pic"]];
            }
            else{
                [_avatarImageView setImage:[UIImage imageNamed:@"home_user_example_pic"]];
            }
            //TODO 个人信息补全后添加
            [_hospitalLabel setText:@""];
            [_departAndJobLabel setText: @""];
        }
    }

}

- (void)setMyInfoView {
    NSString *icon = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserIcon"];
    if (icon && icon.length > 0) {
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"home_user_example_pic"]];
    }
    else {
        [_avatarImageView setImage:[UIImage imageNamed:@"home_user_example_pic"]];
    }
    [_nameLabel setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"]];
    [_hospitalLabel setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserHospital"]];
    NSString *department = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserDepartment"];
    NSString *jobTitle = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserJobTitle"];
    if (department == nil) {
        department = @"";
    }
    if (jobTitle == nil) {
        jobTitle = @"";
    }
    NSString *infoString = [NSString stringWithFormat:@"%@ %@", department, jobTitle];
    [_departAndJobLabel setText:infoString];
}

-(void)loadAllShuoshuoAndDaylog
{
    if (!_currentDoctorId) {
        return;
    }
    myContentArray = [NSMutableArray array];
    repostContentArray = [NSMutableArray array];
    NSDictionary *params = @{
                             @"doctorid": _currentDoctorId
                             };
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DoctorAPI DoctorShuoshuoWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@",responseObject);
        for (NSDictionary *dict in responseObject) {
            if (!dict) {
                continue;
            }
            if ([dict[@"type"]intValue] == 1) {
                ShuoShuo *shuoshuo = [[ShuoShuo alloc]initWithShuoShuoId:dict[@"id"] doctorId:dict[@"doctorid"] title:dict[@"title"] content:dict[@"content"] createTime:[NSDate dateWithTimeIntervalSince1970:[dict[@"createtime"]intValue]]];
                if ([dict[@"doctorid"]intValue] == _currentDoctorId.intValue) {
                    [myContentArray addObject:shuoshuo];
                }else {
                    [repostContentArray addObject:shuoshuo];
                }
            } else if ([dict[@"type"]intValue] == 2) {
                DayLog *dayLog = [[DayLog alloc]initWithDayLogId:dict[@"id"] doctorId:dict[@"doctorid"] title:dict[@"title"] content:dict[@"content"] createTime:[NSDate dateWithTimeIntervalSince1970:[dict[@"createtime"]intValue]]];
                if ([dict[@"doctorid"]intValue] == _currentDoctorId.intValue) {
                    [myContentArray addObject:dayLog];
                } else {
                    [repostContentArray addObject:dayLog];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:NO];
            [self.contentTableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
    
}

- (void)deleteShuoShuoByShuoShuo:(ShuoShuo *)shuoshuo {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"删除说说中...";
    NSDictionary *delparams = @{
                                @"doctorid": _currentDoctorId,
                                @"id" : shuoshuo.shuoshuoId,
                                @"type" : @1 //1为说说 2为日志
                                };
    [DoctorAPI delDoctorShuoshuoOrDaylogWithParameters:delparams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dic[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        [myContentArray removeObject:shuoshuo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contentTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentIndexPathRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.0f];
    }];

}

- (void)editButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:@"MyPageContentEditTalkSegueIdentifier" sender:sender];
}

- (void)deleteButtonClicked:(UIButton *)sender {
    currentIndexPathRow = ((UIButton *)sender).tag;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认删除这条说说?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
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
        
    } else if ([segue.identifier isEqualToString:@"MyPageContentEditTalkSegueIdentifier"]) {
        ShuoShuo *shuoshuo = myContentArray[((UIButton *)sender).tag];
        UINavigationController *nav = [segue destinationViewController];
        MyPageContentTalkViewController *vc = nav.viewControllers[0];
        [vc setCurrentShuoShuo:shuoshuo];
    } else if ([segue.identifier isEqualToString:@"MyPageContentArticleDetailSegueIdentifier"]) {
        MyPageContentArticleDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.contentTableView indexPathForSelectedRow];
        if (_contentTypeSegmentControl.selectedSegmentIndex) {
            [vc setCurrentDayLog:repostContentArray[indexPath.row]];
        }else{
            [vc setCurrentDayLog:myContentArray[indexPath.row]];
        }
    }
}
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)contentTypeChanged:(id)sender {
    [self.contentTableView reloadData];
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
    if (_contentTypeSegmentControl.selectedSegmentIndex) {
        return repostContentArray.count;
    } else{
        return myContentArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyPageContentTalkTableViewCellIdentifier = @"MyPageContentTalkTableViewCellIdentifier";
    static NSString *MyPageContentArticleTableViewCellIdentifier = @"MyPageContentArticleTableViewCell";
    id content;
    if (_contentTypeSegmentControl.selectedSegmentIndex) {
        content = repostContentArray[indexPath.row];
    } else {
        content = myContentArray[indexPath.row];
    }
    if ([content isKindOfClass:[ShuoShuo class]]) {
        MyPageContentTalkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyPageContentTalkTableViewCellIdentifier forIndexPath:indexPath];
        [cell setShuoshuo:content];
        [cell.editButton setTag:indexPath.row];
        [cell.editButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton setTag:indexPath.row];
        [cell.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else if ([content isKindOfClass:[DayLog class]]) {
        MyPageContentArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyPageContentArticleTableViewCellIdentifier forIndexPath:indexPath];
        [cell setDayLog:content];
        return cell;
    }
    return nil;
}


#pragma mark - DZNEmptyDataSrouce
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无内容"];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        ShuoShuo *shuoshuo = myContentArray[currentIndexPathRow];
        [self deleteShuoShuoByShuoShuo:shuoshuo];
    }
}

@end
