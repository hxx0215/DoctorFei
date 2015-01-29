//
//  AgendaArrangementTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/13.
//
//

#import "AgendaArrangementTableViewController.h"
#import "TimeScheduleTableViewCell.h"
#import "DoctorAPI.h"
@implementation AgendaArrangementTableViewController
{
    NSArray *dayarrangeDicArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadDayarrange];
}

-(void)loadDayarrange
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"topnum": @0
                             };
    [DoctorAPI getDoctorDayarrangeWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        dayarrangeDicArray = [responseObject copy];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dayarrangeDicArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TimeScheduleTableViewCell *cell = [[TimeScheduleTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    NSDictionary *dic = [dayarrangeDicArray objectAtIndex:indexPath.row];
    cell.textLabel.text = dic[@"membername"];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"12313123123";
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 31.0f;
}

@end
