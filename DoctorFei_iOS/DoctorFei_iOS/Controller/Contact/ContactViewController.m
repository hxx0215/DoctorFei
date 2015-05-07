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
#import <RHAddressBook.h>
#import "RHPerson.h"
#import "UserAPI.h"
#import "ContactInviteTableViewCell.h"
#import "NSString+PinYinUtil.h"

@import MessageUI;
@interface ContactViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UISearchDisplayDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (copy, nonatomic) NSArray *stableTableData;
@property (strong, nonatomic) NSMutableArray *cellSelected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
- (IBAction)segmentValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVIewTopConstraint;

@property (nonatomic, strong) RHAddressBook *addressbook;

@end

@implementation ContactViewController
{
    NSArray *friendArray, *tableViewDataArray, *needInvitePersonArray;
    NSMutableArray *searchResultArray;
    NSIndexPath *currentIndexPath;
    MBProgressHUD *smsHud;
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
    
    
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined) {
        [[[RHAddressBook alloc]init] requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
            if (!granted) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有获取到通讯录权限, 将不能使用推荐功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                self.addressbook = nil;
            }else{
                self.addressbook = [[RHAddressBook alloc]init];
                [self checkNeedInviteArray];
            }
        }];
    }
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusDenied || [RHAddressBook authorizationStatus] == RHAuthorizationStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有获取到通讯录, 将不能使用推荐功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        self.addressbook = nil;
    }
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusAuthorized) {
        self.addressbook = [[RHAddressBook alloc]init];
    }
    if (_addressbook) {
        [self checkNeedInviteArray];
    }
}

- (void)checkNeedInviteArray {
    NSArray *peoples = _addressbook.people;
    NSMutableDictionary *checkDict = [NSMutableDictionary dictionary];
    NSMutableArray *checkArray = [NSMutableArray array];
    for (RHPerson *person in peoples) {
        NSString *phoneString = [person.phoneNumbers valueAtIndex:0];
        if (phoneString.length > 0) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"-| |\\+86|\\(|\\)" options:0 error:nil];
            NSMutableString *needReplacePhone = [phoneString copy];
            NSString *phone = [regex stringByReplacingMatchesInString:needReplacePhone options:0 range:NSMakeRange(0, needReplacePhone.length) withTemplate:@""];
            [checkArray addObject:phone];
            [checkDict setObject:phone forKey:@(person.recordID)];
        }
    }
    NSString *checkString = [checkArray componentsJoinedByString:@","];
//    NSLog(@"%@",checkString);
    NSDictionary *param = @{
                            @"mobile": checkString
                            };
    [UserAPI checkFriendIsRegisterWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
        NSMutableArray *needArray = [NSMutableArray array];
        for (NSDictionary *dict in responseObject) {
            if (dict[@"isjoin"] && [dict[@"isjoin"] intValue] == 0) {
                NSString *phone = dict[@"mobile"];
                NSArray *recordIdArray = [checkDict allKeysForObject:phone];
                for (NSNumber *recordId in recordIdArray) {
                    RHPerson *person = [_addressbook personForABRecordID:recordId.intValue];
                    if (![needArray containsObject:person]) {
                        [needArray addObject:person];
                    }
                }
            }
        }
        
        needInvitePersonArray = [needArray sortedArrayUsingComparator:^NSComparisonResult(RHPerson *obj1,RHPerson *obj2){
            NSString *st1 = [obj1.name getFirstCharPinYin];
            NSString *st2 = [obj2.name getFirstCharPinYin];
            return [st1 compare:st2 options:NSCaseInsensitiveSearch];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
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
    [self fetchFriendWithUsertype:[self currentUserType]];
    [self shouldShowSegment];
    [self reloadTableViewDataWithUserType:[self currentUserType]];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)shouldShowSegment{
    switch (self.contactMode) {
        case ContactViewControllerModeNormal:
        case ContactViewControllerModeCreateGroup:
        case ContactViewControllerModeGMAddFriend:
        case ContactViewControllerModeMainGroupAddFriend:
            self.segmentControl.hidden = NO;
            break;
        case ContactViewControllerModeTransfer:
        case ContactViewControllerModeConsultation:
            self.tableVIewTopConstraint.constant = -38;
            self.segmentControl.hidden = YES;
            self.segmentControl.selectedSegmentIndex = 0;
            break;
        case ContactViewControllerModeScheduleSelectFriend:
            self.tableVIewTopConstraint.constant = -38;
            self.segmentControl.hidden = YES;
            self.segmentControl.selectedSegmentIndex = 1;
        default:
            break;
    }
}
- (void)reloadTableViewDataWithUserType:(NSNumber *)type {
    friendArray = [Friends MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"userType == %@ && isFriend == %@", type, @YES]];
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
    for (Friends *f in [Friends MR_findAll]){
        if ([self.selectedArray containsObject:f])
            [self.cellSelected addObject:f];
    }
    [self.selectedArray removeAllObjects];
    if (self.cellSelected.count >0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView reloadData];

}
//- (void)reloadTableViewData {
////    friendArray = [Friends MR_findAll];
//    friendArray = [Friends MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"userType == %@ && isFriend == %@", [self currentUserType], @YES]];
////    friendArray = [Friends MR_findByAttribute:@"userType" withValue:[self currentUserType]];
//    
//    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
//    
//    NSMutableArray *mutableSections = [[NSMutableArray alloc]initWithCapacity:sectionTitlesCount];
//    for (int i = 0 ; i < sectionTitlesCount; i ++) {
//        [mutableSections addObject:[NSMutableArray array]];
//    }
//    for (Friends *friend in friendArray) {
//        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation]sectionForObject:friend collationStringSelector:@selector(getFirstCharPinYin)];
//        NSMutableArray *section = mutableSections[sectionNumber];
//        [section addObject:friend];
//    }
//    
//    for (int i = 0; i < sectionTitlesCount; i ++) {
//        NSArray *sortedArrayForSection = [[UILocalizedIndexedCollation currentCollation]sortedArrayFromArray:mutableSections[i] collationStringSelector:@selector(getFirstCharPinYin)];
//        mutableSections[i] = sortedArrayForSection;
//    }
//    
//    
//    
//    tableViewDataArray = mutableSections;
//    for (Friends *f in [Friends MR_findAll]){
//        if ([self.selectedArray containsObject:f])
//            [self.cellSelected addObject:f];
//    }
//    [self.selectedArray removeAllObjects];
//    if (self.cellSelected.count >0)
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    [self.tableView reloadData];
//}

- (void)fetchFriendWithUsertype:(NSNumber *)type {
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": [userId stringValue],
                             @"userType": type
                             };
    [DoctorAPI getFriendsWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *dataArray = (NSArray *)responseObject;
        for (NSDictionary *dict in dataArray) {
            if (dict[@"state"] && [dict[@"state"]intValue] == 0) {
                break;
            }
            Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", @([dict[@"userid"] intValue]), @([dict[@"usertype"]intValue])]];
            if (friend == nil) {
                friend = [Friends MR_createEntity];
                friend.userId = @([dict[@"userid"]intValue]);
            }
            friend.icon = dict[@"icon"];
            friend.realname = dict[@"RealName"];
            friend.gender = @([dict[@"Gender"]intValue]);
            friend.mobile = dict[@"Mobile"];
            friend.noteName = dict[@"notename"];
            friend.situation = dict[@"describe"];
            friend.email = dict[@"Email"];
            friend.hospital = dict[@"hospital"];
            friend.department = dict[@"department"];
            friend.jobTitle = dict[@"jobTitle"];
            friend.otherContact = dict[@"OtherContact"];
            friend.userType = type;
            friend.isFriend = @YES;
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        [self reloadTableViewDataWithUserType: type];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];

}

//- (void)fetchFriend
//{
//    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
//    NSDictionary *params = @{
//                             @"doctorid": [userId stringValue]
//                             };
//    [DoctorAPI getFriendsWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
//        NSString *msg = [[responseObject firstObject] objectForKey:@"msg"];
//        if (msg){//为毛服务器没有数据还要返回个啊哦。真是有病
//            [self reloadTableViewData];
//            return ;
//        }
////        [Friends MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"userType == %@", [self currentUserType]]];
//        NSArray *dataArray = (NSArray *)responseObject;
//        for (NSDictionary *dict in dataArray) {
//            Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", @([dict[@"userid"] intValue]), @([dict[@"usertype"]intValue])]];
////            Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:dict[@"userid"]];
//            if (friend == nil) {
//                friend = [Friends MR_createEntity];
//                friend.userId = @([dict[@"userid"]intValue]);
//            }
//            friend.icon = dict[@"icon"];
//            friend.realname = dict[@"RealName"];
//            friend.gender = @([dict[@"Gender"]intValue]);
//            friend.mobile = dict[@"Mobile"];
//            friend.noteName = dict[@"notename"];
//            friend.situation = dict[@"describe"];
//            friend.email = dict[@"Email"];
//            friend.hospital = dict[@"hospital"];
//            friend.department = dict[@"department"];
//            friend.jobTitle = dict[@"jobTitle"];
//            friend.otherContact = dict[@"OtherContact"];
//            friend.userType = @([dict[@"usertype"]intValue]);
//            friend.isFriend = @YES;
//        }
//        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
//        [self reloadTableViewData];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = @"错误";
//        hud.detailsLabelText = error.localizedDescription;
//        [hud hide:YES afterDelay:1.5f];
//    }];
//}
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
//        Chat *chat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat: @"type <= %@ AND ANY user == %@", @3, currentFriend]];
//        if (chat == nil) {
//            chat = [Chat MR_createEntity];
//            if (currentFriend.userType.intValue == 2) {
//                chat.type = @1;
//            }else{
//                chat.type = @0;
//            }
//            [chat addUserObject:currentFriend];
////            chat.user = [chat.user setByAddingObject:currentFriend];
//        }
//        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
//        [vc setCurrentChat:chat];
        Chat *currentChat = nil;
        for (Chat *chat in currentFriend.chat) {
            if (chat.type.intValue < 3) {
                currentChat = chat;
                break;
            }
        }
        if (currentChat == nil) {
            currentChat = [Chat MR_createEntity];
            if (currentFriend.userType.intValue == 2) {
                currentChat.type = @1;
            }else{
                currentChat.type = @0;
            }
            [currentChat addUserObject:currentFriend];
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        }
        [vc setCurrentChat:currentChat];
        
//        vc.isDoctor = (self.segmentControl.selectedSegmentIndex == 0);
//        if (indexPath != nil) {
//            [vc setCurrentFriend:searchResultArray[indexPath.row]];
//            [self.searchDisplayController setActive:NO];
//        }
//        else {
//            indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
//            [vc setCurrentFriend:tableViewDataArray[indexPath.section - 1][indexPath.row]];
//        }
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    }
}
- (IBAction)backButtonClicked:(id)sender {
    if (self.contactMode <2)
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
        switch (self.contactMode) {
            case ContactViewControllerModeCreateGroup:
            case ContactViewControllerModeConsultation:
            case ContactViewControllerModeTransfer:
            case ContactViewControllerModeScheduleSelectFriend:
            case ContactViewControllerModeMainGroupAddFriend:{
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    self.didSelectFriends([self.cellSelected copy]);
                }];
            }
                break;
            default:{
                self.didSelectFriends(self.cellSelected);
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
        }
    }
}
- (IBAction)segmentValueChanged:(id)sender {
    [self fetchFriendWithUsertype:[self currentUserType]];
    [self reloadTableViewDataWithUserType:[self currentUserType]];
}

- (IBAction)inviteButtonClicked:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        RHPerson *person = needInvitePersonArray[((UIButton *)sender).tag];
        MFMessageComposeViewController *mf = [[MFMessageComposeViewController alloc]init];
        mf.messageComposeDelegate = self;
        mf.navigationBar.tintColor = UIColorFromRGB(0x6EA800);
        mf.body = @"";
        mf.recipients = @[[person.phoneNumbers valueAtIndex:0]];
        [self presentViewController:mf animated:YES completion:nil];
        smsHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        smsHud.removeFromSuperViewOnHide = YES;
    }else{
        smsHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        smsHud.removeFromSuperViewOnHide = YES;
        smsHud.mode = MBProgressHUDModeText;
        smsHud.labelText = @"设备不支持发送短信";
        [smsHud hide:YES afterDelay:1.0f];
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
    if (self.contactMode == ContactViewControllerModeNormal){
        return tableViewDataArray.count + 1 + (needInvitePersonArray.count > 0 ? 1 : 0);
    }
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
        else if (section == tableViewDataArray.count + 1){
            return needInvitePersonArray.count;
        }
        else
            return [tableViewDataArray[section - 1] count];
    }
    else
        return [tableViewDataArray[section] count];
//    return friendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *ContactFriendCellIdentifier = @"ContactFriendCellIdentifier";
    static NSString *ContactInviteCellIdentifier = @"ContactInviteCellIdentifier";
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ContactFriendTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ContactFriendCellIdentifier];
        [cell setDataFriend:searchResultArray[indexPath.row]];
        cell.contactMode = ContactViewControllerModeNormal;
        return cell;
    }
    else if (indexPath.section == tableViewDataArray.count + 1){
        ContactInviteTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ContactInviteCellIdentifier forIndexPath:indexPath];
        [cell setPerson:needInvitePersonArray[indexPath.row]];
        [cell.inviteButton setTag:indexPath.row];
        [cell.inviteButton addTarget:self action:@selector(inviteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
            cell.selectedButton.selected = [self.cellSelected containsObject:tableViewDataArray[indexPath.section][indexPath.row]];
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
            else if (section == tableViewDataArray.count + 1){
                return @"以下朋友还没有注册,赶紧邀请他们吧";
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"ContactDetailSegueIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
        return;
    }
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
        {
            if (indexPath.section<[tableViewDataArray count] + 1){
                [self performSegueWithIdentifier:@"ContactDetailSegueIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
            }else{
                ContactInviteTableViewCell *cell = (ContactInviteTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                [self inviteButtonClicked:cell.inviteButton];
            }
        }
    }
    else{
        ContactFriendTableViewCell *cell = (ContactFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selectedButton.selected = !cell.selectedButton.selected;
        if (self.contactMode == ContactViewControllerModeTransfer || self.contactMode == ContactViewControllerModeScheduleSelectFriend){
            for (Friends *f in self.cellSelected){
                ContactFriendTableViewCell *tCell = nil;
                for (int i=0;i<tableViewDataArray.count;i++)
                    for (int j=0;j<[tableViewDataArray[i] count];j++){
                        if ([f isEqual:tableViewDataArray[i][j]]){
                            NSIndexPath *path = [NSIndexPath indexPathForRow:j inSection:i];
                            tCell = (ContactFriendTableViewCell *)[tableView cellForRowAtIndexPath:path];
                        }
                    }
                if (tCell){
                    tCell.selectedButton.selected = NO;
                }
            }
            [self.cellSelected removeAllObjects];
        }
        if (cell.selectedButton.selected)
            [self.cellSelected addObject:tableViewDataArray[indexPath.section][indexPath.row]];
        else
            [self.cellSelected removeObject:tableViewDataArray[indexPath.section][indexPath.row]];
        if ([self.cellSelected count]<1)
            self.navigationItem.rightBarButtonItem.enabled = NO;
        else
            self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *emptyString;
    if (_segmentControl.selectedSegmentIndex == 0) {
        emptyString = @"暂无医生好友";
    }else if (_segmentControl.selectedSegmentIndex == 1){
        emptyString = @"暂无患者好友";
    }else if (_segmentControl.selectedSegmentIndex == 2) {
        emptyString = @"暂无家属好友";
    }
    NSAttributedString *emptyTitle = [[NSAttributedString alloc]initWithString:emptyString];
    return emptyTitle;
}
#pragma mark - DZNEmptySetDelegate

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    Friends *friend = tableViewDataArray[currentIndexPath.section - 1][currentIndexPath.row];
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
                for (Chat *chat in friend.chat) {
                    if (chat.type.intValue < 3) {
                        [chat MR_deleteEntity];
                    }
                }
//                Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:friend];
//                if (chat) {
//                    [chat MR_deleteEntity];
//                }
                [friend MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
                [self reloadTableViewDataWithUserType:[self currentUserType]];
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

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    smsHud.mode = MBProgressHUDModeText;
    switch (result) {
        case MessageComposeResultCancelled:
            //取消
            smsHud.labelText = @"邀请取消";
            break;
        case MessageComposeResultSent:
            //发送成功
            smsHud.labelText = @"邀请发送成功";
            break;
        case MessageComposeResultFailed:
            //发送失败
            smsHud.labelText = @"邀请发送失败";
            break;
            
        default:
            break;
    }
    [smsHud hide:YES afterDelay:1.0f];
    [controller dismissViewControllerAnimated:YES completion:nil];

}
@end
