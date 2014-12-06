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
#import "Friends.h"
#import "ContactFriendTableViewCell.h"
#import "ContactDetailViewController.h"
@interface ContactViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ContactViewController
{
    NSArray *friendArray;
    NSMutableArray *searchResultArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    searchResultArray = [NSMutableArray array];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self fetchFriend];
    [self reloadTableViewData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableViewData {
    friendArray = [Friends MR_findAll];
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
            friend.userType = dict[@"usertype"];
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
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ContactDetailViewController *vc = [segue destinationViewController];
        [vc setCurrentFriend:friendArray[indexPath.row]];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResultArray.count;
    }
    return friendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    static NSString *ContactFriendCellIdentifier = @"ContactFriendCellIdentifier";
    ContactFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactFriendCellIdentifier forIndexPath:indexPath];
    [cell setDataFriend:friendArray[indexPath.row]];
    return cell;

}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *emptyTitle = [[NSAttributedString alloc]initWithString:@"暂无患者"];
    return emptyTitle;
}
#pragma mark - DZNEmptySetDelegate
@end
