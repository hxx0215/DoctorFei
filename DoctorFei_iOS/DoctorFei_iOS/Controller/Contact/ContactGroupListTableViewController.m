//
//  ContactGroupListTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/14/15.
//
//

#import "ContactGroupListTableViewController.h"
#import "ContactViewController.h"
//#import "Chat.h"
#import "ChatAPI.h"
#import "ContactDetailViewController.h"
#import <MBProgressHUD.h>
#import <JSONKit.h>
#import "Friends.h"
#import "GroupChat.h"
#import "Chat.h"
@interface ContactGroupListTableViewController ()

@end

@implementation ContactGroupListTableViewController
{
    NSArray *groupArray;
    NSMutableArray *searchResultArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    searchResultArray = [NSMutableArray array];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [UIView new];
    [self reloadTableViewData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
                            @"usertype": @2,
                            };
    [ChatAPI getChatGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *dataArray = (NSArray *)responseObject;
        if ([dataArray firstObject][@"state"] && [[dataArray firstObject][@"state"]intValue] == 0) {
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = [dataArray firstObject][@"msg"];
//            [hud hide:YES afterDelay:1.0f];
        }else{
//            [GroupChat MR_truncateAll];
//            [Chat MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @5]];
            [GroupChat MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"chat == nil"]];
            for (NSDictionary *dict in dataArray) {
                GroupChat *groupChat = [GroupChat MR_findFirstByAttribute:@"groupId" withValue:@([dict[@"groupid"] intValue])];
                if (groupChat == nil) {
                    groupChat = [GroupChat MR_createEntity];
                    groupChat.groupId = @([dict[@"groupid"] intValue]);
                }
                groupChat.name = dict[@"name"];
//                Chat *receiveChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ && chatId == %@", @5, @([dict[@"groupid"] intValue])]];
//                if (receiveChat == nil) {
//                    receiveChat = [Chat MR_createEntity];
//                    receiveChat.chatId = @([dict[@"groupid"] intValue]);
//                }
//                receiveChat.type = @5;
//                receiveChat.title = dict[@"name"];
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
                            @"usertype": @2,
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
                            @"usertype": @2
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
    return groupArray.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactGroupListCellIdentifier"];
        cell.textLabel.text = [searchResultArray[indexPath.row] name];
        cell.textLabel.textColor = [UIColor blackColor];
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactGroupListCellIdentifier" forIndexPath:indexPath];
        if (indexPath.row == 0){
            cell.textLabel.text = NSLocalizedString(@"新建群", nil);
            cell.textLabel.textColor = [UIColor colorWithRed:127.0/255 green:203.0/255.0 blue:62.0/255.0 alpha:1.0];
        }else{
            cell.textLabel.text = [groupArray[indexPath.row - 1] name];
            cell.textLabel.textColor = [UIColor blackColor];
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0){
        [self performSegueWithIdentifier:@"ContactCreateGroupSequeIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }else{
        [self performSegueWithIdentifier:@"ContactGroupDetailSegueIdentifier" sender:indexPath];
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [self deleteChatGroupWithIndexPath:indexPath];
////        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactCreateGroupSequeIdentifier"]) {
        UINavigationController *nav = [segue destinationViewController];
        ContactViewController *contact = nav.viewControllers.firstObject;
        contact.contactMode = ContactViewControllerModeCreateGroup;
        contact.didSelectFriends = ^(NSArray *friends){
            [self createChatGroupWithUserArray:friends];
        };

    }else if ([segue.identifier isEqualToString:@"ContactGroupDetailSegueIdentifier"]){
        NSIndexPath *indexPath = (NSIndexPath *)sender;
//        Chat *selectedChat = groupArray[indexPath.row - 1];
        GroupChat *selectedGroupChat = groupArray[indexPath.row - 1];
        Chat *selectedChat = selectedGroupChat.chat;
//        Chat *selectedChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"ANY groupChat == %@", selectedGroupChat]];
        if (selectedChat == nil) {
            selectedChat = [Chat MR_createEntity];
            selectedChat.chatId = selectedGroupChat.groupId;
            selectedChat.type = @3;
            selectedChat.user = selectedGroupChat.member;
            selectedChat.title = selectedGroupChat.name;
            selectedGroupChat.chat = selectedChat;
        }
        ContactDetailViewController *vc = [segue destinationViewController];
        [vc setCurrentChat:selectedChat];
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

@end
