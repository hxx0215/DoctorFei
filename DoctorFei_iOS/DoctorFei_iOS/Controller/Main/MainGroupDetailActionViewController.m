//
//  MainGroupDetailActionViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/19.
//
//

#import "MainGroupDetailActionViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "MainGroupTableViewCell.h"
#import "MainGroupSelectTableViewCell.h"
#import "Groups.h"
#import "DoctorAPI.h"
#import "MainGroupGroupActionViewController.h"
#import <MBProgressHUD.h>
#import "Friends.h"
@interface MainGroupDetailActionViewController ()
    <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewHeight;

@end

@implementation MainGroupDetailActionViewController
{
    NSMutableArray *groupArray;
}
@synthesize vcMode = _vcMode;
@synthesize selectedFriend = _selectedFriend;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    if (_vcMode == MainGroupDetailActionViewControllerModeEdit) {
        self.title = @"编辑分组";
        self.navigationItem.rightBarButtonItems = nil;
    } else{
        self.title = @"选择分组";
//        self.navigationItem.leftBarButtonItems = nil;
        self.headViewHeight.constant = 0;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchGroupArray];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainGroupEditGroupSegueIdentifier"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UINavigationController *nav = [segue destinationViewController];
        MainGroupGroupActionViewController *vc = nav.viewControllers[0];
        [vc setCurrentGroup:groupArray[indexPath.row]];
    }
}

- (void)reloadTableViewData {
    [self.tableView reloadData];
    if (_selectedFriend.group) {
        NSUInteger row = [groupArray indexOfObject:_selectedFriend.group];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)moveFriend:(Friends *)friend toGroup:(Groups *)group {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorId,
                            @"groupid": group.groupId,
                            @"userids": [friend.userId stringValue]
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"移动中...";
    [DoctorAPI moveDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dict[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([dict[@"state"]intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                friend.group = group;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)fetchGroupArray {
    groupArray = [NSMutableArray array];
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorId,
                            @"sortype": @0
                            };
    [DoctorAPI getDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        for (NSDictionary *dict in responseObject) {
            if (dict[@"state"] && [dict[@"state"]intValue] == 0) {
                NSLog(@"%@",dict[@"msg"]);
                break;
            }
            Groups *group = [Groups MR_findFirstByAttribute:@"groupId" withValue:dict[@"id"]];
            if (group == nil) {
                group = [Groups MR_createEntity];
                group.groupId = dict[@"id"];
            }
            group.title = dict[@"title"];
            group.total = dict[@"total"];
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        groupArray = [[Groups MR_findAll]mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableViewData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
}

- (void)deleteGroupWithIndexPath:(NSIndexPath *)indexPath {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"删除中...";
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    Groups *group = groupArray[indexPath.row];
    NSDictionary *param = @{
                            @"doctorid": doctorId,
                            @"groupid": group.groupId
                            };
    [DoctorAPI delDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dict[@"msg"];
        if ([dict[@"state"]intValue] == 1) {
            [group MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            [groupArray removeObject:group];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        }
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES
     ];
}

- (IBAction)confirmButtonClicked:(id)sender {
    Groups *selectGroup = groupArray[[self.tableView indexPathForSelectedRow].row];
    [self moveFriend:_selectedFriend toGroup:selectGroup];
}


#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MainGroupCellIdentifier = @"MainGroupCellIdentifier";
    static NSString *MainGroupSelectCellIdentifier = @"MainGroupSelectCellIdentifier";
    if (_vcMode == MainGroupDetailActionViewControllerModeEdit) {
        MainGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainGroupCellIdentifier forIndexPath:indexPath];
        [cell setCurrentGroup: groupArray[indexPath.row]];
        return cell;
    }else{
        MainGroupSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainGroupSelectCellIdentifier forIndexPath:indexPath];
        [cell setCurrentGroup:groupArray[indexPath.row]];
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteGroupWithIndexPath:indexPath];
    }
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}
#pragma mark - DZNEmptyDataSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    return [[NSAttributedString alloc]initWithString:@"暂无分组"];
}
@end
