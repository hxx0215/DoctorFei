//
//  ContactMainViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/28.
//
//

#import "ContactMainViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "ContactFriendTableViewCell.h"
#import "Friends+PinYinUtil.h"
#import "MemberAPI.h"
#import <MBProgressHUD.h>
#import "ContactDetailViewController.h"
#import "Chat.h"
@interface ContactMainViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *cellSelected;
- (IBAction)segmentValueChanged:(id)sender;
@end

@implementation ContactMainViewController
{
    NSArray *friendArray, *tableViewDataArray;
    NSMutableArray *searchResultArray;
    NSIndexPath *currentIndexPath;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [Friends MR_truncateAll];
    searchResultArray = [NSMutableArray array];
    
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView setSectionIndexColor:[UIColor blackColor]];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.searchDisplayController.searchResultsTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.cellSelected = [NSMutableArray new];
    switch (self.contactMode) {
        case ContactMainViewControllerModeNormal:
            self.navigationItem.leftBarButtonItem = nil;
            break;
        case ContactMainViewControllerModeCreateGroup:
            [self.rightItem setTitle:@"确定"];
            self.rightItem.enabled = NO;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchFriendWithUserType:[self currentUserType]];
    [self reloadTableViewDataWithUserType:[self currentUserType]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactDetailSegueIdentifier"]) {
        ContactDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:(UITableViewCell *)sender];
        Friends *currentFriend;
        if (indexPath != nil) {
            currentFriend = searchResultArray[indexPath.row];
            [self.searchDisplayController setActive:NO];
        }
        else {
            indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
            currentFriend = tableViewDataArray[indexPath.section - 1][indexPath.row];
        }
        Chat *chat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat: @"type <= %@ AND ANY user == %@", @2, currentFriend]];
        if (chat == nil) {
            chat = [Chat MR_createEntity];
            chat.type = @0;
            chat.user = [chat.user setByAddingObject:currentFriend];
        }
        [vc setCurrentChat:chat];

//        if (indexPath != nil) {
//            [vc setCurrentFriend:searchResultArray[indexPath.row]];
//            [self.searchDisplayController setActive:NO];
//        }
//        else {
//            indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
//            [vc setCurrentFriend:tableViewDataArray[indexPath.section - 1][indexPath.row]];
//        }

    }
}

#pragma mark - Actions
- (NSNumber *)currentUserType {
    switch (_segmentControl.selectedSegmentIndex) {
        case 0:
            return @2;
            break;
        case 1:
            return @0;
            break;
        case 2:
            return @1;
            break;
        default:
            break;
    }
    return @0;
}
- (void)fetchFriendWithUserType:(NSNumber *)type {
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"usertype": type
                            };
    [MemberAPI getFriendsWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *dataArray = (NSArray *)responseObject;
        for (NSDictionary *dict in dataArray) {
            if (dict[@"state"] && [dict[@"state"]intValue] == 0) {
                break;
            }
            Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:dict[@"userid"]];
            if (friend == nil) {
                friend = [Friends MR_createEntity];
                friend.userId = @([dict[@"userid"]intValue]);
            }
            friend.email = dict[@"Email"];
            friend.gender = dict[@"Gender"];
            friend.mobile = dict[@"Mobile"];
            friend.realname = dict[@"RealName"];
            friend.icon = dict[@"icon"];
//            friend.userType = @([dict[@"usertype"]intValue]);
            friend.noteName = dict[@"notename"];
            friend.situation = dict[@"describe"];
            friend.userType = type;
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableViewDataWithUserType:type];
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
- (void)reloadTableViewDataWithUserType:(NSNumber *)type {
    friendArray = [Friends MR_findByAttribute:@"userType" withValue:type];
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

    
    [self.tableView reloadData];
}
- (IBAction)segmentValueChanged:(id)sender {
    [self fetchFriendWithUserType:[self currentUserType]];
    [self reloadTableViewDataWithUserType:[self currentUserType]];
}
- (IBAction)backButtonClicked:(id)sender {
    if (_contactMode == ContactMainViewControllerModeCreateGroup) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)rightItemClicked:(id)sender {
    switch (self.contactMode) {
        case ContactMainViewControllerModeNormal:
            [self performSegueWithIdentifier:@"ContactAddFriendsSegueIdentifier" sender:sender];
            break;
        case ContactMainViewControllerModeCreateGroup:
        {
            self.didSelectFriend(self.cellSelected);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        default:
            break;
    }
}
#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20.0f;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.000001f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (self.contactMode) {
        case ContactMainViewControllerModeCreateGroup:
        {
            ContactFriendTableViewCell *cell =(ContactFriendTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            cell.selectedButton.selected = !cell.selectedButton.selected;
            if (cell.selectedButton.selected)
                [self.cellSelected addObject:tableViewDataArray[indexPath.section][indexPath.row]];
            else
                [self.cellSelected removeObject:tableViewDataArray[indexPath.section][indexPath.row]];
            self.rightItem.enabled = (self.cellSelected.count > 0);
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResultArray.count;;
    }
    if (self.contactMode == ContactMainViewControllerModeCreateGroup){
        return [tableViewDataArray[section] count];
    }
    if (section == 0) {
        return 3;
    }else{
        return [tableViewDataArray[section - 1] count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    if (self.contactMode == ContactMainViewControllerModeCreateGroup){
        return tableViewDataArray.count;
    }
    return tableViewDataArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactFriendCellIdentifier = @"ContactFriendCellIdentifier";
    static NSString *ContactNewFriendCellIdentifier = @"ContactNewFriendCellIdentifier";
    static NSString *ContactGroupTalkCellIdentifier = @"ContactGroupTalkCellIdentifier";
    static NSString *ContactNearByCellIdentifier = @"ContactNearByCellIdentifier";
    static NSString *ContactFriendSelectCellIdentifier = @"ContactFriendSelectCellIdentifier";
    if (self.contactMode == ContactMainViewControllerModeNormal)
    {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                {
                    return [tableView dequeueReusableCellWithIdentifier:ContactNewFriendCellIdentifier forIndexPath:indexPath];
                }
                    break;
                case 1:
                {
                    return [tableView dequeueReusableCellWithIdentifier:ContactGroupTalkCellIdentifier forIndexPath:indexPath];
                }
                    break;
                case 2:
                {
                    return [tableView dequeueReusableCellWithIdentifier:ContactNearByCellIdentifier forIndexPath:indexPath];
                }
                    break;
                default:
                    break;
            }
        }
        else{
            ContactFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactFriendCellIdentifier forIndexPath:indexPath];
            [cell setCurrentFriend:tableViewDataArray[indexPath.section - 1][indexPath.row]];
            return cell;
        }
    }else{
        ContactFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactFriendSelectCellIdentifier forIndexPath:indexPath];
        [cell setCurrentFriend:tableViewDataArray[indexPath.section][indexPath.row]];
        if ([self.cellSelected containsObject:tableViewDataArray[indexPath.section][indexPath.row]]){
            cell.selectedButton.selected = YES;
        }
        return cell;
    }
    
    return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    else if (self.contactMode == ContactMainViewControllerModeNormal){
        if (section == 0){
            return @" ";
        }
        else{
            if ([tableViewDataArray[section - 1] count] > 0) {
                return [[[UILocalizedIndexedCollation currentCollation]sectionTitles]objectAtIndex:section - 1];
            }
        }
    }else if (self.contactMode == ContactMainViewControllerModeCreateGroup){
        if ([tableViewDataArray[section] count]>0)
            return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    NSArray *allTitles = [[UILocalizedIndexedCollation currentCollation]sectionIndexTitles];
    return allTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - DZNEmptyDatasource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无好友"];
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
