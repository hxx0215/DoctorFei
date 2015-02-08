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
@interface MainGroupDetailViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIActionSheetDelegate>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainGroupDetailViewController
{
    NSArray *friendArray;
}
@synthesize currentGroup = _currentGroup;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainGroupChangeSegueIdentifier"]) {
        MainGroupDetailActionViewController *vc = [segue destinationViewController];
        [vc setVcMode:MainGroupDetailActionViewControllerModeSelect];
        //TODO
    }
}

- (void)viewDidLoad {
    [self.tableView setTableFooterView:[UIView new]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(tableviewCellLongPressed:)];
    longPress.minimumPressDuration = 1.0;

    [self.tableView addGestureRecognizer:longPress];
}

- (void)reloadTableViewData {
    if (_currentGroup) {
        friendArray = [Friends MR_findFirstByAttribute:@"group" withValue:_currentGroup];
    }else {
        friendArray = [Friends MR_findAll];
    }
    [self.tableView reloadData];
}

- (void)fetchFriendWithGroup: (Groups *)group {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber *doctorid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSNumber *groupid = _currentGroup ? _currentGroup.groupId : @0;
    NSNumber *usertype = @0;
    NSDictionary *param = @{
                            @"doctorid": doctorid,
                            @"sortype": @0,
                            @"groupid": groupid,
                            @"usertype": usertype
                            };
    [DoctorAPI getFriendsWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:NO];
        NSLog(@"%@",responseObject);
        for (NSDictionary *dict in responseObject) {
            Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:dict[@"userId"]];
            if (friend == nil) {
                friend.userId = dict[@"userId"];
            }
            friend.userType = usertype;
            friend.email = dict[@"Email"];
            friend.gender = dict[@"Gender"];
            friend.mobile = dict[@"Mobile"];
            friend.realname = dict[@"RealName"];
            friend.icon = dict[@"icon"];
//            friend.userType = dict[@"usertype"];
            friend.noteName = dict[@"notename"];
            friend.situation = dict[@"describe"];
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableViewData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        
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
        UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转移到其他组",@"从该组删除", nil];
        [sheet showFromTabBar:self.tabBarController.tabBar];
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
    }
    
    
}


#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
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
        [self performSegueWithIdentifier:@"MainGroupChangeSegueIdentifier" sender:nil];
    }
}
@end
