//
//  ContactGroupListTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/14/15.
//
//

#import "ContactGroupListTableViewController.h"
#import "ContactMainViewController.h"
//#import "Chat.h"
#import "ChatAPI.h"
#import "ContactDetailViewController.h"
#import <MBProgressHUD.h>
#import <JSONKit.h>
#import "Friends.h"
#import "GroupChat.h"
#import "Chat.h"
#import "ContactGroupListTableViewCell.h"
#import "ContactGroupNewTypeTableViewCell.h"
#import "ContactGroupNewGeneralViewController.h"
@interface ContactGroupListTableViewController ()

@end

@implementation ContactGroupListTableViewController
{
    NSArray *groupArray;
    NSMutableArray *searchResultArray;
}
+ (NSArray *)titles
{
    static NSArray *_titles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _titles = @[@{@"name": @"新建同城群",
                      @"descript": @"会展示附近的群中, 结识周围新朋友"},
                    @{@"name": @"新建私密群",
                      @"descript": @"仅通过通讯录添加好友, 完全私密的交流空间"},
                    @{@"name": @"附近的群",
                      @"descript": @"查找和加入附近的群, 结识周围新朋友"}
                    ];
    });
    return _titles;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    searchResultArray = [NSMutableArray array];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [UIView new];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTableViewData];
    [self fetchChatGroup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - NetActions
- (void)reloadTableViewData{
    //    groupArray = [Chat MR_findByAttribute:@"type" withValue:@5];
    groupArray = [GroupChat MR_findAllSortedBy:@"groupId" ascending:YES];
    [self.tableView reloadData];
}

- (void)fetchChatGroup{
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": userId,
                            @"usertype": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserType"],
                            };
    [ChatAPI getChatGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *dataArray = (NSArray *)responseObject;
        if ([dataArray firstObject][@"state"] && [[dataArray firstObject][@"state"]intValue] == 0) {
        }else{
            [GroupChat MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"chat == nil"]];
            for (NSDictionary *dict in dataArray) {
                GroupChat *groupChat = [GroupChat MR_findFirstByAttribute:@"groupId" withValue:@([dict[@"groupid"] intValue])];
                if (groupChat == nil) {
                    groupChat = [GroupChat MR_createEntity];
                    groupChat.groupId = @([dict[@"groupid"] intValue]);
                }
                groupChat.name = dict[@"name"];
                groupChat.flag = @([dict[@"flag"] intValue]);
                groupChat.address = [dict[@"address"] isKindOfClass:[NSString class]] ? dict[@"address"] : nil;
                groupChat.taxis = @([dict[@"taxis"] intValue]);
                groupChat.latitude = @([dict[@"lat"]doubleValue]);
                groupChat.longtitude = @([dict[@"long"]doubleValue]);
                groupChat.visible = @([dict[@"visible"] intValue]);
                groupChat.icon = dict[@"icon"];
                groupChat.note = [dict[@"note"] isKindOfClass:[NSString class]] ? dict[@"note"]: nil;
                groupChat.total = @([dict[@"total"]intValue]);
                groupChat.allowDisturb = @([dict[@"allowdisturb"] intValue]);
            }
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableViewData];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)createChatGroupWithUserArray:(NSArray *)userArray {
    NSMutableArray *joinArray = [NSMutableArray array];
    for (Friends *friend in userArray) {
        NSDictionary *friendDict = @{
                                     @"id":friend.userId,
                                     @"type":friend.userType
                                     };
        [joinArray addObject:friendDict];
    }
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": userId,
                            @"usertype": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserType"],
                            @"name": @"未命名",
                            @"joinuserids": [joinArray JSONString],
                            };
    [ChatAPI setChatGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *result = [responseObject firstObject];
        if ([result[@"state"] intValue] == 1) {
            GroupChat *groupChat = [GroupChat MR_createEntity];
            groupChat.groupId = @([result[@"curid"]intValue]);
            groupChat.name = @"未命名";
            //            Chat *groupChat = [Chat MR_createEntity];
            //            groupChat.type = @5;
            //            groupChat.title = @"未命名";
            //            groupChat.chatId = @([result[@"curid"]intValue]);
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableViewData];
            });
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = result[@"msg"];
            [hud hide:YES afterDelay:1.5f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)deleteChatGroupWithIndexPath: (NSIndexPath *)indexPath{
    GroupChat *groupChat = groupArray[indexPath.row - 1];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"groupid": groupChat.groupId,
                            @"userid": userId,
                            @"usertype": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserType"]
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [ChatAPI delChatGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = result[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([result[@"state"] intValue] == 1) {
            [groupChat MR_deleteEntity];
            //            [chat MR_deleteEntity];
            //            groupArray = [Chat MR_findByAttribute:@"type" withValue:@5];
            groupArray = [GroupChat MR_findAll];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResultArray.count;
    }
    return groupArray.count + 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactGroupTypeCellIdentifier = @"ContactGroupTypeCellIdentifier";
    static NSString *ContactGroupListCellIdentifier = @"ContactGroupListCellIdentifier";
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ContactGroupListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ContactGroupListCellIdentifier];
        [cell setCurrentGroupChat:searchResultArray[indexPath.row]];
        return cell;
        //        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactGroupListCellIdentifier"];
        //        cell.textLabel.text = [searchResultArray[indexPath.row] name];
        //        cell.textLabel.textColor = [UIColor blackColor];
        //        return cell;
    }
    else{
        if (indexPath.row < 3) {
            ContactGroupNewTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactGroupTypeCellIdentifier forIndexPath:indexPath];
            [cell.nameLabel setText:[[self class]titles][indexPath.row][@"name"]];
            [cell.descriptionLabel setText:[[self class]titles][indexPath.row][@"descript"]];
            return cell;
        }
        else{
            ContactGroupListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactGroupListCellIdentifier forIndexPath:indexPath];
            [cell setCurrentGroupChat:groupArray[indexPath.row - 3]];
            return cell;
            //            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactGroupListCellIdentifier" forIndexPath:indexPath];
            //            if (indexPath.row == 0){
            //                cell.textLabel.text = NSLocalizedString(@"新建群", nil);
            //                cell.textLabel.textColor = [UIColor colorWithRed:127.0/255 green:203.0/255.0 blue:62.0/255.0 alpha:1.0];
            //            }else{
            //                cell.textLabel.text = [groupArray[indexPath.row - 1] name];
            //                cell.textLabel.textColor = [UIColor blackColor];
            //            }
            //            return cell;
        }
    }
    return nil;
}
#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 77.0f;
    }
    if (indexPath.row < 3) {
        return 58.0f;
    }else{
        return 77.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        GroupChat *groupChat = searchResultArray[indexPath.row];
        [self performSegueWithIdentifier:@"ContactGroupDetailSegueIdentifier" sender:groupChat];
    }
    else if (indexPath.row == 0){
        [self performSegueWithIdentifier:@"ContactGroupCreateNewLocationSegueIdentifier" sender:nil];
    }else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"ContactGroupNewPrivateSegueIdentifier" sender:nil];
    }else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"ContactGroupNearbySegueIdentifier" sender:nil];
    }else{
        GroupChat *groupChat = groupArray[indexPath.row - 3];
        [self performSegueWithIdentifier:@"ContactGroupDetailSegueIdentifier" sender:groupChat];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactCreateGroupSequeIdentifier"]) {
        UINavigationController *nav = [segue destinationViewController];
        ContactMainViewController *contact = nav.viewControllers.firstObject;
        contact.contactMode = ContactMainViewControllerModeCreateGroup;
        contact.didSelectFriend = ^(NSArray *friends){
            [self createChatGroupWithUserArray:friends];
        };
        
    }else if ([segue.identifier isEqualToString:@"ContactGroupDetailSegueIdentifier"]){
        GroupChat *groupChat = (GroupChat *)sender;
        Chat *selectedChat = groupChat.chat;
        //        Chat *selectedChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"ANY groupChat == %@", selectedGroupChat]];
        if (selectedChat == nil) {
            selectedChat = [Chat MR_createEntity];
            selectedChat.chatId = groupChat.groupId;
            selectedChat.type = @3;
            selectedChat.user = groupChat.member;
            selectedChat.title = groupChat.name;
            groupChat.chat = selectedChat;
        }
        ContactDetailViewController *vc = [segue destinationViewController];
        [vc setCurrentChat:selectedChat];
    }else if ([segue.identifier isEqualToString:@"ContactGroupNewPrivateSegueIdentifier"]) {
        ContactGroupNewGeneralViewController *vc = [segue destinationViewController];
        [vc setVcMode:ContactGroupNewModePrivate];
    }
}

#pragma mark - UISearchDisplayController Delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [searchResultArray removeAllObjects];
    for (GroupChat *groupChat in groupArray) {
        NSRange foundRange = [groupChat.name rangeOfString:searchString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
        if (foundRange.length > 0) {
            [searchResultArray addObject:groupChat];
        }
    }
    return YES;
}


- (IBAction)backToListVC:(UIStoryboardSegue *)segue{
    
}
@end
