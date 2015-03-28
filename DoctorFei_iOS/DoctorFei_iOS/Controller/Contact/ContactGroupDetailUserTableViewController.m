//
//  ContactGroupDetailUserTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/24.
//
//

#import "ContactGroupDetailUserTableViewController.h"
#import "ContactGroupUserCollectionViewCell.h"
#import "Chat.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
#import "ChatAPI.h"
#import "MBProgressHUD.h"
#import "GroupChat.h"
#import "GroupChatFriend.h"
#import "ContactGroupDetailInfoTableViewController.h"
#import "ContactViewController.h"
#import "JSONKit.h"
static NSString *ContactGroupUserCellIdentifier = @"ContactGroupUserCellIdentifier";
@interface ContactGroupDetailUserTableViewController ()
    <UICollectionViewDelegate, UICollectionViewDataSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ContactGroupDetailUserTableViewController
{
    NSArray *userArray, *userDataArray;
    BOOL isCanDeleteUser;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    [self.tableView setTableFooterView:[UIView new]];
    
    [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
    
    CGRect headRect = self.tableView.tableHeaderView.frame;
    headRect.size.height = 200.0f;
    [self.tableView.tableHeaderView setFrame:headRect];
//    [self reloadCollectionViewData];
    isCanDeleteUser = NO;
    [self fetchChatUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _nameLabel.text = _currentGroupChat.name;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadCollectionViewData{
//    userArray = _currentChat.user.allObjects;
    userArray = _currentGroupChat.member.allObjects;
    [self.collectionView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGRect headRect = self.tableView.tableHeaderView.frame;
    headRect.size.height = self.collectionView.contentSize.height + 20;
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView setFrame:headRect];
    [self.tableView setTableHeaderView:headerView];
}
- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)fetchChatUser{
    NSDictionary *param = @{@"groupid": _currentGroupChat.groupId};
    [ChatAPI getChatUserWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
        userDataArray = (NSArray *)responseObject;
        for (NSDictionary *dict in responseObject) {
            if ([dict[@"userid"] intValue] == [doctorId intValue] && [dict[@"usertype"] intValue] == 2) {
                isCanDeleteUser = ([dict[@"role"] intValue] == 2);
                continue;
            }
            Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", @([dict[@"userid"] intValue]), @([dict[@"usertype"] intValue])]];
            if (friend == nil) {
                friend = [Friends MR_createEntity];
                friend.userId = @([dict[@"userid"] intValue]);
                friend.userType = @([dict[@"usertype"] intValue]);
            }
            GroupChatFriend *groupChatFriend = [GroupChatFriend MR_findFirstByAttribute:@"id" withValue:@([dict[@"id"] intValue])];
            if (groupChatFriend == nil) {
                groupChatFriend = [GroupChatFriend MR_createEntity];
                groupChatFriend.id = @([dict[@"id"] intValue]);
            }
            groupChatFriend.name = dict[@"name"];
            groupChatFriend.createTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"ctime"]intValue]];
            groupChatFriend.role = @([dict[@"role"] intValue]);
            groupChatFriend.friend = friend;
            [_currentGroupChat addMemberObject:groupChatFriend];
            [_currentGroupChat.chat addUserObject:friend];
//            [_currentChat addUserObject:friend];
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadCollectionViewData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)deleteUserWithFriend:(Friends *)friend {
    NSNumber *friendId = nil;
    for (NSDictionary *dict in userDataArray) {
        if ([dict[@"userid"] intValue] == friend.userId.intValue && [dict[@"usertype"]intValue] == friend.userType.intValue){
            friendId = @([dict[@"id"] intValue]);
            break;
        }
    }
    if (friendId) {
        NSDictionary *param = @{@"id": friendId,
                                @"groupid" : _currentGroupChat.groupId,
                                @"userid": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],
                                @"usertype": @2
                                };
        [ChatAPI delChatUserWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
}

- (void)addUserWithUserArray:(NSArray *)array {
    NSMutableArray *joinArray = [NSMutableArray array];
    for (Friends *friend in array) {
        [joinArray addObject:@{@"id": friend.userId, @"type": friend.userType}];
    }
    NSDictionary *param = @{
                            @"groupid": _currentGroupChat.groupId,
                            @"userid": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],
                            @"usertype": @2,
                            @"joinuserids": [joinArray JSONString]
                            };
    NSLog(@"%@",param);
    [ChatAPI setChatUserWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = [responseObject firstObject][@"msg"];
        [hud hide:YES afterDelay:1.5f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        
    }];
}

- (void)changeDeleteButtonState {
    for (int i = 0; i < userArray.count ; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i + 1 inSection:0];
        ContactGroupUserCollectionViewCell *cell = (ContactGroupUserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell.deleteButton setHidden:!cell.deleteButton.isHidden];
    }
}
- (void)deleteUserButtonClicked:(UIButton *)sender {
    NSInteger tag = sender.tag;
    Friends *deleteFriend = userArray[tag];
    [self deleteUserWithFriend:deleteFriend];
}
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return userArray.count + (isCanDeleteUser ? 2 : 3);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ContactGroupUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ContactGroupUserCellIdentifier forIndexPath:indexPath];
    if (indexPath.item > 0 && indexPath.item < userArray.count + 1) {
//        Friends *friend = userArray[indexPath.item - 1];
        GroupChatFriend *friend = userArray[indexPath.item - 1];
        [cell.nameLabel setText:friend.name];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.friend.icon]    placeholderImage:[UIImage imageNamed:@"details_uers_example_pic"]];
    }else if (indexPath.item == 0) {
        NSString *name = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"];
        NSString *icon = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserIcon"];
        [cell.nameLabel setText:name];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"details_uers_example_pic"]];
    }else if (indexPath.item == userArray.count + 1){
        [cell.nameLabel setText:@""];
        [cell.imageView setImage:[UIImage imageNamed:@"add_user_btn"]];
    }else if (indexPath.item == userArray.count + 2){
        [cell.nameLabel setText:@""];
        [cell.imageView setImage:[UIImage imageNamed:@"minus-user_btn"]];
    }
    [cell.deleteButton setHidden:YES];
    [cell.deleteButton setTag:indexPath.item - 1];
    [cell.deleteButton addTarget:self action:@selector(deleteUserButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        return;
    }else if (indexPath.item == userArray.count + 1){
        [self performSegueWithIdentifier:@"ContactGroupDetailAddMemberSegueIdentifier" sender:nil];
    }else if (indexPath.item == userArray.count + 2){
        [self changeDeleteButtonState];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactGroupDetailInfoSegueIdentifier"]) {
        ContactGroupDetailInfoTableViewController *vc = [segue destinationViewController];
        [vc setGroupChat:_currentGroupChat];
    }else if ([segue.identifier isEqualToString:@"ContactGroupDetailAddMemberSegueIdentifier"]) {
        UINavigationController *nav = [segue destinationViewController];
        ContactViewController *contact = nav.viewControllers.firstObject;
        contact.contactMode = ContactViewControllerModeCreateGroup;
        contact.selectedArray = [_currentGroupChat.chat.user.allObjects mutableCopy];
        contact.didSelectFriends = ^(NSArray *friends){
            NSLog(@"%@",friends);
            [self addUserWithUserArray:friends];
        };

    }
}


@end
