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
@interface ContactNewFriendViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ContactNewFriendViewController
{
    NSMutableArray *invitationsArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setTableFooterView:[UIView new]];
    [self fetchNewFriendInvation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)fetchNewFriendInvation {
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"usertype": @0 //TODO 尚无家属类型相关处理
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

- (void)setFriendInvitationWithIndex:(NSInteger) index{
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSMutableDictionary *dict = [invitationsArray[index]mutableCopy];
    NSDictionary *param = @{
                            @"userid": memberId,
                            @"usertype": @0,
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
    return invitationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NewFriendCellIdentifier = @"NewFriendCellIdentifier";
    ContactNewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewFriendCellIdentifier forIndexPath:indexPath];
    [cell setDataDict:invitationsArray[indexPath.row]];
    [cell.agreeButton addTarget:self action:@selector(agreeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.agreeButton setTag:indexPath.row];
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0f;
}

#pragma mark - DZNEmpty Datasource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无新好友请求"];
}

@end
