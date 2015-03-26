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
static NSString *ContactGroupUserCellIdentifier = @"ContactGroupUserCellIdentifier";
@interface ContactGroupDetailUserTableViewController ()
    <UICollectionViewDelegate, UICollectionViewDataSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ContactGroupDetailUserTableViewController
{
    NSArray *userArray, *userDataArray;
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
    [self fetchChatUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadCollectionViewData{
    userArray = _currentChat.user.allObjects;
    [self.collectionView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGRect headRect = self.tableView.tableHeaderView.frame;
    headRect.size.height = self.collectionView.contentSize.height;
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView setFrame:headRect];
    [self.tableView setTableHeaderView:headerView];
}
- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)fetchChatUser{
    NSDictionary *param = @{@"groupid": _currentChat.chatId};
    [ChatAPI getChatUserWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
        userDataArray = (NSArray *)responseObject;
        for (NSDictionary *dict in responseObject) {
            if ([dict[@"userid"] intValue] == [doctorId intValue] && [dict[@"usertype"] intValue] == 2) {
                continue;
            }
            Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", @([dict[@"userid"] intValue]), @([dict[@"usertype"] intValue])]];
            if (friend == nil) {
                friend = [Friends MR_createEntity];
                friend.userId = @([dict[@"userid"] intValue]);
                friend.userType = @([dict[@"usertype"] intValue]);
            }
            friend.realname = dict[@"name"];
            [_currentChat addUserObject:friend];
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
    //TODO
}
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return userArray.count + 3;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ContactGroupUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ContactGroupUserCellIdentifier forIndexPath:indexPath];
    if (indexPath.item > 0 && indexPath.item < userArray.count + 1) {
        Friends *friend = userArray[indexPath.item - 1];
        [cell.nameLabel setText:friend.realname];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.icon]    placeholderImage:[UIImage imageNamed:@"details_uers_example_pic"]];
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
        //TODO 继续添加人员
    }else if (indexPath.item == userArray.count + 2){
        [self changeDeleteButtonState];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
