//
//  ContactGroupMessageListViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/4/18.
//
//

#import "ContactGroupMessageListViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "ChatAPI.h"
#import "ContactGroupMessageTableViewCell.h"
@interface ContactGroupMessageListViewController ()
    <DZNEmptyDataSetSource, UITableViewDelegate, UITableViewDataSource>
- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ContactGroupMessageListViewController
{
    NSMutableArray *groupMessageArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    groupMessageArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchGroupMessage {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": doctorId,
                            @"usertype": @2
                            };
    [ChatAPI getChatGroupSendWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject firstObject][@"state"] == nil) {
            groupMessageArray = [((NSArray *)responseObject) mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
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

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groupMessageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactGroupMessageCellIdentifier = @"ContactGroupMessageCellIdentifier";
    ContactGroupMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactGroupMessageCellIdentifier forIndexPath:indexPath];
    [cell setDataDict:groupMessageArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableView Delegate

#pragma mark - DZNEmptyDatasource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无群聊信息"];
}
@end
