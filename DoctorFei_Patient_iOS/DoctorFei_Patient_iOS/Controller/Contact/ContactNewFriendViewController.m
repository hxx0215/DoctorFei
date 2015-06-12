//
//  ContactNewFriendViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import "ContactNewFriendViewController.h"
#import "FriendAPI.h"
#import <MBProgressHUD.h>
#import <UIScrollView+EmptyDataSet.h>
#import "ContactNewFriendTableViewCell.h"
#import "UserAPI.h"
#import "ContactNewFriendGroupTableViewCell.h"
#import "ChatAPI.h"
@interface ContactNewFriendViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ContactNewFriendViewController
{
    NSMutableArray *invitationsArray, *newListArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setTableFooterView:[UIView new]];
    [self fetchNewFriendInvation];
    [self fetchNewList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)fetchNewFriendInvation {
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"usertype": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserType"]
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FriendAPI getInvitationWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:NO];
        NSArray *resultArray = (NSArray *)responseObject;
        if (resultArray.firstObject[@"state"] && [resultArray.firstObject[@"state"] intValue] == 0) {
            
        }else{
            invitationsArray = [resultArray mutableCopy];
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
- (void)fetchNewList {
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"usertype": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserType"]
                            };
    [UserAPI getFriendNewListWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject count] > 0) {
            if ([responseObject firstObject][@"state"]) {
            }
            else {
                newListArray = [(NSArray *)responseObject mutableCopy];
                [self.tableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)setFriendInvitationWithIndex:(NSInteger) index{
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSMutableDictionary *dict = [invitationsArray[index]mutableCopy];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"usertype": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserType"],
                            @"id": dict[@"id"],
                            @"type": @1
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [FriendAPI setInvitationWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = result[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([result[@"state"] intValue] == 1) {
            [dict setObject:@1 forKey:@"isaudit"];
            [invitationsArray replaceObjectAtIndex:index withObject:dict];
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)agreeButtonClicked:(id)sender {
    [self setFriendInvitationWithIndex:[sender tag]];
}
#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return invitationsArray.count + newListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NewFriendCellIdentifier = @"NewFriendCellIdentifier";
    static NSString *NewFriendGroupCellIdentifier = @"NewFriendGroupCellIdentifier";
    if (indexPath.row < newListArray.count) {
        ContactNewFriendGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewFriendGroupCellIdentifier forIndexPath:indexPath];
        [cell setDict:newListArray[indexPath.row]];
        return cell;
    }
    else {
        ContactNewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewFriendCellIdentifier forIndexPath:indexPath];
        [cell setDataDict:invitationsArray[indexPath.row - newListArray.count]];
        [cell.agreeButton addTarget:self action:@selector(agreeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.agreeButton setTag:(indexPath.row - newListArray.count)];
        return cell;
    }
//    ContactNewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewFriendCellIdentifier forIndexPath:indexPath];
//    [cell setDataDict:invitationsArray[indexPath.row]];
//    [cell.agreeButton addTarget:self action:@selector(agreeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.agreeButton setTag:indexPath.row];
//    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row < newListArray.count) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSDictionary *dict = newListArray[indexPath.row];
        NSDictionary *param = @{@"rid":dict[@"id"],
                                @"isaudit": @3};
        [ChatAPI setChatAuditWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            [newListArray removeObject:dict];
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }
}
#pragma mark - DZNEmpty Datasource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无新好友请求"];
}

@end
