//
//  AgendaArrangementTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/13.
//
//

#import "AgendaArrangementTableViewController.h"
#import "AgendaArrangementTableViewCell.h"
#import "DoctorAPI.h"
#import "AgendaArrangement.h"
#import <UIScrollView+EmptyDataSet.h>
#import <MBProgressHUD.h>

@interface AgendaArrangementTableViewController ()
    <DZNEmptyDataSetSource>

@end

@implementation AgendaArrangementTableViewController
{
    NSArray *dayarrangeDicArray;
    NSMutableOrderedSet *dateSet;
    NSMutableDictionary *arrangeDict;
    NSDateFormatter *dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadDayarrange];
}

-(void)loadDayarrange
{
    dateSet = [NSMutableOrderedSet orderedSet];
    arrangeDict = [NSMutableDictionary dictionary];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"topnum": @0
                             };
    [DoctorAPI getDoctorDayarrangeWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        for (NSDictionary *dict in responseObject) {
            AgendaArrangement *arrangement = [[AgendaArrangement alloc]init];
            arrangement.title = dict[@"title"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dict[@"daytime"] intValue]];
            arrangement.dayTime = date;
            arrangement.memberName = dict[@"membername"];
            NSString *dateString = [dateFormatter stringFromDate:date];
            [dateSet addObject:dateString];
            NSMutableArray *arrangeDateArray = arrangeDict[dateString];
            if (!arrangeDateArray) {
                arrangeDateArray = [NSMutableArray array];
            }
            [arrangeDateArray addObject:arrangement];
            [arrangeDict setObject:arrangeDateArray forKey:dateString];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:NO];
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dateSet.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray *)arrangeDict[dateSet[section]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AgendaArragnementTableViewCellIdentifier = @"AgendaArragnementTableViewCellIdentifier";
    AgendaArrangementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AgendaArragnementTableViewCellIdentifier forIndexPath:indexPath];
    NSMutableArray *arrangeDateArray = arrangeDict[dateSet[indexPath.section]];
    [cell setArrangement:arrangeDateArray[indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return dateSet[section];
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 31.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

#pragma mark - DZNEmptyDataSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无日志"];
}
@end
