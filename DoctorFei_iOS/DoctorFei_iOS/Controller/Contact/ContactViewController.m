//
//  ContactViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "ContactViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
//#import "Friends.h"
#import "ContactFriendTableViewCell.h"
#import "ContactDetailViewController.h"
#import "Friends+PinYinUtil.h"
#import "Chat.h"
#import "Message.h"
#import "DataUtil.h"
@interface ContactViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (copy, nonatomic) NSArray *stableTableData;
@property (strong, nonatomic) NSMutableArray *cellSelected;
@end

@implementation ContactViewController
{
    NSArray *friendArray, *tableViewDataArray;
    NSMutableArray *searchResultArray;
    NSIndexPath *currentIndexPath;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    searchResultArray = [NSMutableArray array];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setSectionIndexColor:[UIColor blackColor]];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.searchDisplayController.searchResultsTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(tableviewCellLongPressed:)];
    longPress.minimumPressDuration = 1.0;
    [self.tableView addGestureRecognizer:longPress];
    [self initStableTableData];
    if (self.contactMode == ContactViewControllerModeNormal)
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else{
        if (self.contactMode == ContactViewControllerModeGMAddFriend){
            self.navigationItem.rightBarButtonItem.title =NSLocalizedString(@"确定", nil);
        }
        else{
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"确定", nil);
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    self.cellSelected = [NSMutableArray new];
}

- (void)initStableTableData{
    self.stableTableData = @[
    @{@"RealName": NSLocalizedString(@"新朋友", nil),@"icon":@"address-list_01.png"},
    @{@"RealName": NSLocalizedString(@"群聊", nil),@"icon":@"address-list_02.png"},
    @{@"RealName": NSLocalizedString(@"群发信息", nil),@"icon":@"address-list_03.png"},
    @{@"RealName": NSLocalizedString(@"附近的人", nil),@"icon":@"address-list_04.png"}];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchFriend];
    [self reloadTableViewData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableViewData {
    friendArray = [Friends MR_findAll];
    
    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    
    NSMutableArray *mutableSections = [[NSMutableArray alloc]initWithCapacity:sectionTitlesCount];
    for (int i = 0 ; i < sectionTitlesCount; i ++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    for (Friends *friend in friendArray) {
        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation]sectionForObject:friend collationStringSelector:@selector(getFirstCharPinYin)];
        NSMutableArray *section = mutableSections[sectionNumber];
        [section addObject:friend];
    }
    
    for (int i = 0; i < sectionTitlesCount; i ++) {
        NSArray *sortedArrayForSection = [[UILocalizedIndexedCollation currentCollation]sortedArrayFromArray:mutableSections[i] collationStringSelector:@selector(getFirstCharPinYin)];
        mutableSections[i] = sortedArrayForSection;
    }
    
    
    
    tableViewDataArray = mutableSections;
    for (int i=0;i< [tableViewDataArray count];i++){
        for (int j=0;j<[tableViewDataArray[i] count];j++){
            NSString *title = [DataUtil nameStringForFriend:tableViewDataArray[i][j]].string;
            [self.selectedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                NSString *friendName = (NSString *)obj;
                if ([friendName isEqualToString:title]){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    [self.cellSelected addObject:indexPath];
                    [self.selectedArray removeObject:friendName];
                    self.navigationItem.rightBarButtonItem.enabled = YES;//self.cellSelected肯定不为空
                }
            }];
        }
    }
    [self.tableView reloadData];
}

- (void)fetchFriend
{
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": [userId stringValue]
                             };
    [DoctorAPI getFriendsWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *dataArray = (NSArray *)responseObject;
        for (NSDictionary *dict in dataArray) {
            Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:dict[@"userId"]];
            if (friend == nil) {
                friend = [Friends MR_createEntity];
                friend.userId = dict[@"userId"];
            }
            friend.email = dict[@"Email"];
            friend.gender = dict[@"Gender"];
            friend.mobile = dict[@"Mobile"];
            friend.realname = dict[@"RealName"];
            friend.icon = dict[@"icon"];
            friend.userType = @([dict[@"usertype"]intValue]);
            friend.noteName = dict[@"notename"];
            friend.situation = dict[@"describe"];
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        [self reloadTableViewData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactDetailSegueIdentifier"]) {
        ContactDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:(UITableViewCell *)sender];
        if (indexPath != nil) {
            [vc setCurrentFriend:searchResultArray[indexPath.row]];
            [self.searchDisplayController setActive:NO];
        }
        else {
            indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
            [vc setCurrentFriend:tableViewDataArray[indexPath.section - 1][indexPath.row]];
        }
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    }
}
- (IBAction)backButtonClicked:(id)sender {
    if (self.contactMode <3)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
}
- (IBAction)rightButtonClicked:(id)sender {
    if (self.contactMode == ContactViewControllerModeNormal){
        [self performSegueWithIdentifier:@"ContactAddFriendSegueIdentifier" sender:sender];
    }
    else{
        NSMutableArray *didSelect = [NSMutableArray new];
//        for (int i=0;i<tableViewDataArray.count;i++){
//            if (self.cellSelected[i])
//                [didSelect addObject:tableViewDataArray[i]];
//        }
        for (NSIndexPath *indexPath in self.cellSelected){
            NSString *title = [DataUtil nameStringForFriend:tableViewDataArray[indexPath.section][indexPath.row]].string;
            [didSelect addObject:title];
        }
        if (self.selectedArray){
            [self.selectedArray addObjectsFromArray:didSelect];
        }
        else
            self.selectedArray = didSelect;
        switch (self.contactMode) {
            case ContactViewControllerModeCreateGroup:{
                [self.navigationController popToRootViewControllerAnimated:NO];
                self.didSelectFriends(self.selectedArray);
            }
                break;
            case ContactViewControllerModeConsultation:{
                [self.navigationController dismissViewControllerAnimated:NO completion:^{
                    self.didSelectFriends(self.selectedArray);
                }];
            }
            case ContactViewControllerModeTransfer:{
                [self.navigationController dismissViewControllerAnimated:NO completion:^{
                    self.didSelectFriends(self.selectedArray);
                }];
            }
                break;
            case ContactViewControllerModeScheduleSelectFriend:{
                NSIndexPath *indexPath = self.cellSelected.firstObject;
                Friends *selectedFriend = tableViewDataArray[indexPath.section][indexPath.row];
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    self.didSelectFriends(@[selectedFriend]);
                }];
            }
                break;
            case ContactViewControllerModeMainGroupAddFriend:{
                NSMutableArray *selectedFriendArray = [NSMutableArray array];
                for (NSIndexPath *indexPath in self.cellSelected) {
                    Friends *selectedFriend = tableViewDataArray[indexPath.section][indexPath.row];
                    [selectedFriendArray addObject:selectedFriend];
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    self.didSelectFriends([selectedFriendArray copy]);
                }];
            }
                break;
            default:{
                self.didSelectFriends(self.selectedArray);
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
        }
    }
}

#pragma mark - UITableViewCellLongPressed
-(void)tableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        CGPoint ponit=[gestureRecognizer locationInView:self.tableView];
        NSIndexPath* path=[self.tableView indexPathForRowAtPoint:ponit];
        currentIndexPath = path;
//        NSLog(@"row:%ld",(long)path.row);
        UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除好友",@"清空聊天记录", nil];
        sheet.tag = 123;
//        [sheet showInView:self.view];
        [sheet showFromTabBar:self.tabBarController.tabBar];
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //未用
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //未用
    }
    
    
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    if (self.contactMode == ContactViewControllerModeNormal)
        return tableViewDataArray.count + 1;
    return tableViewDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResultArray.count;
    }
    if (self.contactMode == ContactViewControllerModeNormal)
    {
        if (section == 0)
            return [self.stableTableData count];
        else
            return [tableViewDataArray[section - 1] count];
    }
    else
        return [tableViewDataArray[section] count];
//    return friendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *ContactFriendCellIdentifier = @"ContactFriendCellIdentifier";
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ContactFriendTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ContactFriendCellIdentifier];
        [cell setDataFriend:searchResultArray[indexPath.row]];
        return cell;
    }
    else{
        ContactFriendTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ContactFriendCellIdentifier forIndexPath:indexPath];
        if (self.contactMode == ContactViewControllerModeNormal)
        {
            if (indexPath.section == 0)
            {
                [cell setStableData:self.stableTableData[indexPath.row]];
            }
            else{
                [cell setDataFriend:tableViewDataArray[indexPath.section - 1][indexPath.row]];
            }
        }
        else
        {
            [cell setDataFriend:tableViewDataArray[indexPath.section][indexPath.row]];
            cell.selectedButton.selected = [self.cellSelected containsObject:indexPath];
        }
        cell.contactMode = self.contactMode;
        return cell;
    }
    return nil;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    else
        if (self.contactMode == ContactViewControllerModeNormal)
        {
            if (section == 0){
                return @" ";
            }
            else{
                if ([tableViewDataArray[section - 1] count] > 0) {
                    return [[[UILocalizedIndexedCollation currentCollation]sectionTitles]objectAtIndex:section - 1];
                }
            }
        }
        else{
            if ([tableViewDataArray[section] count] > 0) {
                return [[[UILocalizedIndexedCollation currentCollation]sectionTitles]objectAtIndex:section];
            }
        }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    NSMutableArray *existTitles = [NSMutableArray array];
    NSArray *allTitles = [[UILocalizedIndexedCollation currentCollation]sectionIndexTitles];
    for (int i = 0 ; i < allTitles.count; i ++) {
        if ([tableViewDataArray[i] count] > 0) {
            [existTitles addObject:allTitles[i]];
        }
    }
//    return existTitles;
    return allTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contactMode == ContactViewControllerModeNormal)
    {
        if (indexPath.section == 0)
        {
            switch (indexPath.row){
                case 0:{
                    [self performSegueWithIdentifier:@"ContactNewFriendSegueIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
                }
                    break;
                case 1:{
                    [self performSegueWithIdentifier:@"ContactGroupListSegueIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
                }
                    break;
                case 2:{
                    [self performSegueWithIdentifier:@"ContactSendGroupMessageSegueIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
                }
                    break;
                case 3:{
                    [self performSegueWithIdentifier:@"ContactNearSegueIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
                }
                default:
                    break;
            }
        }
        else
            [self performSegueWithIdentifier:@"ContactDetailSegueIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    else{
        ContactFriendTableViewCell *cell = (ContactFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selectedButton.selected = !cell.selectedButton.selected;
        if (self.contactMode == ContactViewControllerModeTransfer || self.contactMode == ContactViewControllerModeScheduleSelectFriend){
            for (NSIndexPath *ip in self.cellSelected){
                ContactFriendTableViewCell *tCell = (ContactFriendTableViewCell *)[tableView cellForRowAtIndexPath:ip];
                if (tCell){
                    tCell.selectedButton.selected = NO;
                }
            }
            [self.cellSelected removeAllObjects];
        }
        if (cell.selectedButton.selected)
            [self.cellSelected addObject:indexPath];
        else
            [self.cellSelected removeObject:indexPath];
        if ([self.cellSelected count]<1)
            self.navigationItem.rightBarButtonItem.enabled = NO;
        else
            self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *emptyTitle = [[NSAttributedString alloc]initWithString:@"暂无患者"];
    return emptyTitle;
}
#pragma mark - DZNEmptySetDelegate

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    Friends *friend = tableViewDataArray[currentIndexPath.section][currentIndexPath.row];
    if (buttonIndex == 0) {
        NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
        NSDictionary *params = @{
                                 @"doctorid": doctorId,
                                 @"userid": friend.userId
                                 };
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.dimBackground = YES;
        hud.labelText = @"删除中...";
        [DoctorAPI delFriendWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dict = [responseObject firstObject];
            hud.mode = MBProgressHUDModeText;
            if ([dict[@"state"]intValue] == 1) {
                hud.labelText = @"删除成功";
                Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:friend];
                if (chat) {
                    [chat MR_deleteEntity];
                }
                [friend MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
                [self reloadTableViewData];
            }
            else {
                hud.labelText = @"删除失败";
                hud.detailsLabelText = dict[@"msg"];
            }
            [hud hide:YES afterDelay:1.0f];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error.localizedDescription);
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"错误";
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.0f];
        }];

    }
    else if (buttonIndex == 1) {
        Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:friend];
        if (chat) {
            [chat MR_deleteEntity];
        }
        NSArray *messageArray = [Message MR_findByAttribute:@"user" withValue:friend];
        for (Message *message in messageArray) {
            [message MR_deleteEntity];
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        MBProgressHUD *deleteHud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        deleteHud.mode = MBProgressHUDModeText;
        deleteHud.labelText = @"聊天记录已清除";
        [deleteHud hide:YES afterDelay:1.0f];
    }
}

#pragma mark - UISearchDisplayController Delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [searchResultArray removeAllObjects];
    for (Friends *friend in friendArray) {
        NSString *actionName;
        if (friend.noteName && friend.noteName.length > 0) {
            actionName = friend.noteName;
        }
        else{
            actionName = friend.realname;
        }
        NSRange foundRange = [actionName rangeOfString:searchString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
        if (foundRange.length > 0) {
            [searchResultArray addObject:friend];
        }
    }
    return YES;
}
@end
