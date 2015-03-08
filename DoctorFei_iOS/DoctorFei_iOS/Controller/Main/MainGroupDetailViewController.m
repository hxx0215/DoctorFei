//
//  MainGroupDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/19.
//
//

#import "MainGroupDetailViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "MainGroupDetailActionViewController.h"
#import "Groups.h"
#import "Friends.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import "ContactFriendTableViewCell.h"
#import <WYPopoverController.h>
#import "MainGroupPopoverViewController.h"
#import <WYStoryboardPopoverSegue.h>
@interface MainGroupDetailViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIActionSheetDelegate, WYPopoverControllerDelegate, MainGroupPopoverVCDelegate>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
- (IBAction)titleButtonClciked:(id)sender;

@end

@implementation MainGroupDetailViewController
{
    NSArray *friendArray;
    WYPopoverController *popoverController;
    NSIndexPath *currentIndexPath;
}
@synthesize currentGroup = _currentGroup;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainGroupDetailChangeSegueIdentifier"]) {
        MainGroupDetailActionViewController *vc = [segue destinationViewController];
        [vc setVcMode:MainGroupDetailActionViewControllerModeSelect];
        [vc setSelectedFriend:friendArray[currentIndexPath.row]];
        //TODO
    } else if ([segue.identifier isEqualToString:@"MainGroupDetailPopoverSegueIdentifier"]) {
        UIImage *image = [[UIImage imageNamed:@"top_arrow_up"] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
        [_titleButton setBackgroundImage:image forState:UIControlStateNormal];
        MainGroupPopoverViewController *vc = [segue destinationViewController];
        CGFloat height = 41.0f + 40.0f * ([Groups MR_numberOfEntities].intValue + 1);
        vc.preferredContentSize = CGSizeMake(180.0f, height);
        vc.delegate = self;
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        popoverController = [popoverSegue popoverControllerWithSender:self.titleButton permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        popoverController.delegate = self;
        popoverController.dismissOnTap = YES;
        popoverController.theme.outerCornerRadius = 0;
        popoverController.theme.innerCornerRadius = 0;
        popoverController.theme.glossShadowColor = [UIColor clearColor];
        popoverController.theme.fillTopColor = [UIColor clearColor];
        popoverController.theme.fillBottomColor = [UIColor clearColor];
        popoverController.theme.arrowHeight = 8.0f;
        popoverController.popoverLayoutMargins = UIEdgeInsetsZero;
    } else if ([segue.identifier isEqualToString:@"MainGroupDetailEditSegueIdentifier"]) {
        MainGroupDetailActionViewController *vc = [segue destinationViewController];
        [vc setVcMode:MainGroupDetailActionViewControllerModeEdit];
    } else if ([segue.identifier isEqualToString:@"MainGroupDetailAddFriendSegueIdentifier"]) {
        UINavigationController *nav = [segue destinationViewController];
        ContactViewController *vc = nav.viewControllers.firstObject;
        [vc setContactMode:ContactViewControllerModeMainGroupAddFriend];
        [vc setSelectedArray:[friendArray mutableCopy]];
        vc.didSelectFriends = ^(NSArray *selectArray) {
            NSLog(@"%@",selectArray);
            [self setGroupFriendsWithFriendArray:selectArray];
        };
    }
}

- (void)viewDidLoad {
    [self.tableView setTableFooterView:[UIView new]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(tableviewCellLongPressed:)];
    longPress.minimumPressDuration = 1.0;

    [self.tableView addGestureRecognizer:longPress];
    
    UIImage *image = [[UIImage imageNamed:@"top_arrow_down"]stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    [self.titleButton setBackgroundImage:image forState:UIControlStateNormal];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.titleButton sizeToFit];
    CGRect rect = self.titleButton.frame;
    rect.size.width += 20;
    [self.titleButton setFrame:rect];

}

- (void)reloadView {
    NSString *titleString;
    if (_currentGroup.title) {
        titleString = [NSString stringWithFormat:@"%@", _currentGroup.title];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }else{
        titleString = [NSString stringWithFormat:@"全部"];
        _currentGroup = nil;
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    [self.titleButton setTitle:titleString forState:UIControlStateNormal];
    
    [self fetchFriendWithGroup:_currentGroup];

}

- (void)reloadTableViewData {
    if (_currentGroup) {
        friendArray = [Friends MR_findByAttribute:@"group" withValue:_currentGroup];
    }else {
        friendArray = [Friends MR_findAll];
    }
    [self.tableView reloadData];
}
- (void)fetchGroupArray {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorId,
                            @"sortype": @0
                            };
    [DoctorAPI getDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        for (NSDictionary *dict in responseObject) {
            Groups *group = [Groups MR_findFirstByAttribute:@"groupId" withValue:dict[@"id"]];
            if (group == nil) {
                group = [Groups MR_createEntity];
                group.groupId = dict[@"id"];
            }
            group.title = dict[@"title"];
            group.total = dict[@"total"];
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
//        groupArray = [Groups MR_findAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"MainGroupDetailPopoverSegueIdentifier" sender:nil];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
}

- (void)fetchFriendWithGroup: (Groups *)group {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber *doctorid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSNumber *groupid = _currentGroup.groupId ? _currentGroup.groupId : @0;
    NSNumber *usertype = @0;
    NSDictionary *param = @{
                            @"doctorid": doctorid,
                            @"sortype": @0,
                            @"groupid": groupid,
                            @"usertype": [NSNull null]
                            };
    [DoctorAPI getFriendsWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:NO];
        NSLog(@"%@",responseObject);
        for (NSDictionary *dict in responseObject) {
            if (dict[@"state"] && [dict[@"state"]intValue] == 0) {
                break;
            }
            Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:dict[@"userid"]];
            if (friend == nil) {
                friend = [Friends MR_createEntity];
                friend.userId = dict[@"userid"];
            }
            friend.userType = usertype;
            friend.email = dict[@"Email"];
            friend.gender = dict[@"Gender"];
            friend.mobile = dict[@"Mobile"];
            friend.realname = dict[@"RealName"];
            friend.icon = dict[@"icon"];
            friend.userType = @([dict[@"usertype"]intValue]);
            friend.noteName = dict[@"notename"];
            friend.situation = dict[@"describe"];
            friend.group = _currentGroup;
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableViewData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        
    }];
}

- (void)setGroupFriendsWithFriendArray:(NSArray *)array {
    NSNumber *doctorid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSMutableArray *idArray = [NSMutableArray array];
    for (Friends *friend in array) {
        [idArray addObject:friend.userId];
    }
    NSString *idString = [idArray componentsJoinedByString:@","];
    NSLog(@"%@",idString);
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSDictionary *param = @{
                            @"doctorid" : doctorid,
                            @"groupid": _currentGroup.groupId,
                            @"userids": idString
                            };
    [DoctorAPI moveDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dict[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([dict[@"state"]intValue] == 1) {
            [self fetchFriendWithGroup: _currentGroup];
//            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint point=[gestureRecognizer locationInView:self.tableView];
//        NSIndexPath *path=[self.tableView indexPathForRowAtPoint:point];
        UIActionSheet *sheet;
        if (_currentGroup) {
            sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转移到其他组",@"从该组删除", nil];
        }else{
            sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转移到其他组", nil];
        }
        [sheet showFromTabBar:self.tabBarController.tabBar];
        CGPoint point=[gestureRecognizer locationInView:self.tableView];
        NSIndexPath* path=[self.tableView indexPathForRowAtPoint:point];
        currentIndexPath = path;

    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
    }
    
    
}

- (void)deleteGroupMemberWithFriend:(Friends *)friend {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorId,
                            @"groupid": @0,
                            @"userids": [friend.userId stringValue]
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"删除中...";
    [DoctorAPI moveDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"删除成功";
        [hud hide:YES afterDelay:1.0f];
        if ([dict[@"state"]intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.navigationController popViewControllerAnimated:YES];
                friend.group = nil;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                [self reloadTableViewData];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];


}


#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return friendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MainGroupDetailFriendCellIdentifier = @"MainGroupDetailFriendCellIdentifier";
    ContactFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainGroupDetailFriendCellIdentifier forIndexPath:indexPath];
    [cell setDataFriend:friendArray[indexPath.row]];
    cell.contactMode = ContactViewControllerModeNormal;
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

#pragma mark - DZNEmptyDataSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无人员"];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"MainGroupDetailChangeSegueIdentifier" sender:nil];
    }else if (buttonIndex == 1) {
        [self deleteGroupMemberWithFriend:friendArray[currentIndexPath.row]];
    }
}
- (IBAction)titleButtonClciked:(id)sender {
    [self fetchGroupArray];
}

#pragma mark - WYPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController{
    UIImage *image = [[UIImage imageNamed:@"top_arrow_down"]stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    [_titleButton setBackgroundImage:image forState:UIControlStateNormal];
}

#pragma mark - MainPopover Delegate
- (void)editButtonClickedForPopoverVC:(MainGroupPopoverViewController *)vc {
    [self performSegueWithIdentifier:@"MainGroupDetailEditSegueIdentifier" sender:nil];
}
- (void)groupCellSelectedForPopoverVC:(MainGroupPopoverViewController *)vc withGroup:(Groups *)group {
    _currentGroup = group;
    [self reloadView];
}
@end
