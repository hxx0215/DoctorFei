//
//  ContactNewFriendTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/12/15.
//
//

#import "ContactNewFriendTableViewController.h"
#import "ContactNewFriendTableViewCell.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import "ContactNewFriendGroupTableViewCell.h"
#import "UserAPI.h"
#import "ChatAPI.h"
@interface ContactNewFriendTableViewController ()

@end

@implementation ContactNewFriendTableViewController
{
    NSMutableArray *tableViewDicArray, *newListArray;
    BOOL first;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [UIView new];
    
    tableViewDicArray = [[NSMutableArray alloc]init];
    newListArray = [NSMutableArray array];
    first = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (first) {
        [self loadFriendInvitation];
        [self fetchFriendNewList];
        first = NO;
    }
}
- (void)fetchFriendNewList {
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"usertype": @2,
                             @"userid": [userId stringValue]
                             };
    [UserAPI getFriendNewListWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

-(void)loadFriendInvitation
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"usertype": @2,
                             @"userid": [userId stringValue]
                             };
    [DoctorAPI getFriendInvitationWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject count] > 0) {
            NSArray *dataArray = (NSArray *)responseObject;
            tableViewDicArray = [NSMutableArray array];
            for (NSDictionary *dict in dataArray) {
                [tableViewDicArray addObject:[dict mutableCopy]];
            }
            [self.tableView reloadData];
        }
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return tableViewDicArray.count + newListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ContactNewFriendCellIdentifier";
    static NSString *ContactNewFriendGroupCellIdentifier = @"ContactNewFriendGroupCellIdentifier";
    if (indexPath.row < newListArray.count) {
        ContactNewFriendGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactNewFriendGroupCellIdentifier forIndexPath:indexPath];
        [cell setDict:newListArray[indexPath.row]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else {
        ContactNewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [cell setDataDic:tableViewDicArray[indexPath.row - newListArray.count]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}


// Override to support conditional editing of the table view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
