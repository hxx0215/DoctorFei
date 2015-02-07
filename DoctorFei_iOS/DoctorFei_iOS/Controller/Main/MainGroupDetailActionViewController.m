//
//  MainGroupDetailActionViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/19.
//
//

#import "MainGroupDetailActionViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "MainGroupTableViewCell.h"
#import "MainGroupSelectTableViewCell.h"
#import "Groups.h"
#import "DoctorAPI.h"
@interface MainGroupDetailActionViewController ()
    <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewHeight;

@end

@implementation MainGroupDetailActionViewController
{
    NSArray *groupArray;
}
@synthesize vcMode = _vcMode;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    if (_vcMode == MainGroupDetailActionViewControllerModeEdit) {
        self.title = @"编辑分组";
        self.navigationItem.rightBarButtonItems = nil;
    }
    else{
        self.title = @"选择分组";
        self.navigationItem.leftBarButtonItems = nil;
        self.headViewHeight.constant = 0;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchGroupArray];
}

- (void)fetchGroupArray {
    groupArray = [NSArray array];
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorId,
                            @"sortype": @0
                            };
    [DoctorAPI getDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        for (NSDictionary *dict in responseObject) {
            Groups *group = [Groups MR_findFirstByAttribute:@"groupId" withValue:dict[@"id"]];
            if (group == nil) {
                group = [Groups MR_createEntity];
                group.groupId = dict[@"id"];
            }
            group.title = dict[@"title"];
            group.total = dict[@"total"];
        }
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        groupArray = [Groups MR_findAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
}

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES
     ];
}


#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MainGroupCellIdentifier = @"MainGroupCellIdentifier";
    static NSString *MainGroupSelectCellIdentifier = @"MainGroupSelectCellIdentifier";
    if (_vcMode == MainGroupDetailActionViewControllerModeEdit) {
        MainGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainGroupCellIdentifier forIndexPath:indexPath];
        [cell setCurrentGroup: groupArray[indexPath.row]];
        return cell;
    }else{
        MainGroupSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainGroupSelectCellIdentifier forIndexPath:indexPath];
        [cell setCurrentGroup:groupArray[indexPath.row]];
        return cell;
    }
    return nil;
}
#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}
#pragma mark - DZNEmptyDataSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    return [[NSAttributedString alloc]initWithString:@"暂无分组"];
}
@end
