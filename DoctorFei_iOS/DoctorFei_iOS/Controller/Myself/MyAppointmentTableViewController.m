//
//  MyAppointmentTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/6/15.
//
//

#import "MyAppointmentTableViewController.h"
#import "DoctorAPI.h"
#import "MyAppointmentDetailViewController.h"
#import <UIScrollView+EmptyDataSet.h>
@interface MyAppointmentTableViewController ()
    <DZNEmptyDataSetSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *appointSegment;
@property (nonatomic, strong) NSMutableArray *appointmentData;
@property (nonatomic, strong) NSMutableArray *referralData;
@property (nonatomic, strong) NSMutableArray *tableData;//0为预约信息1为转诊信息
@end

@implementation MyAppointmentTableViewController
static NSString * const kMyAppointmentIdenty = @"MyAppointmentIdenty";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    CGRect headFrame = self.tableView.tableHeaderView.frame;
    headFrame.size.height = 44;
    self.tableView.tableHeaderView.frame = headFrame;
    self.tableData = [NSMutableArray new];
    [self.tableData addObject:[NSMutableArray new]];
    [self.tableData addObject:[NSMutableArray new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
}
//TODO:将获得的数组排序
- (void)sortAppointData{
    self.tableData[0]=[[self.tableData[0] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSString *s1 = obj1[@"addtime"];
        NSString *s2 = obj2[@"addtime"];
        NSDate *date1 = nil;
        NSDate *date2 = nil;
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        date1 = [dateformatter dateFromString:s1];
        date2 = [dateformatter dateFromString:s2];
        if ([s1 isEqualToString:@""]){
            date1 = [NSDate dateWithTimeIntervalSince1970:0];
        }
        if ([s2 isEqualToString:@""]){
            date2 = [NSDate dateWithTimeIntervalSince1970:0];
        }
        return [date2 compare:date1];
    }] mutableCopy];
}
- (void)sortReferralData{
    self.tableData[1] = [[self.tableData[1] sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        return [obj1[@"createtime"] integerValue]<[obj2[@"createtime"] integerValue];
    }] mutableCopy];
}
- (void)refreshData{
    NSDictionary *params = @{@"doctorid": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"],@"sorttype" : @(1)};
    [DoctorAPI getAppointmentWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"appointment:%@",responseObject);
        NSArray *resultArray = (NSArray *)responseObject;
        if (resultArray.firstObject[@"state"] && [resultArray.firstObject[@"state"] intValue] == 0) {
        }else{
            self.tableData[0] = [resultArray mutableCopy];
            [self sortAppointData];
            [self.tableView reloadData];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",error);
    }];
    [DoctorAPI getReferralInfoWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"referral:%@",responseObject);
        NSArray *resultArray = (NSArray *)responseObject;
        if (resultArray.count > 0) {
            self.tableData[1] = [resultArray mutableCopy];
            [self sortReferralData];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",error);
    }];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if ([self.tableData count]>0)
        return [self.tableData[self.appointSegment.selectedSegmentIndex] count];
    else
        return 0;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.appointSegment.selectedSegmentIndex == 0);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSDictionary *params = @{@"id": [self.tableData[0][indexPath.row] objectForKey:@"id"]};
        [DoctorAPI deleteAppointmentWithParameters:params success:^(AFHTTPRequestOperation *operation, id responsObject){
            
        }failure:^(AFHTTPRequestOperation *operation,NSError *error){
            
        }];
        [self.tableData[0] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyAppointmentIdenty forIndexPath:indexPath];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyAppointmentIdenty];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyAppointmentIdenty];
    }
    
    // Configure the cell...
    if (self.appointSegment.selectedSegmentIndex ==0)
        cell.textLabel.text = [self.tableData[self.appointSegment.selectedSegmentIndex][indexPath.row] objectForKey:@"uname"];
    else
        cell.textLabel.text = [self.tableData[self.appointSegment.selectedSegmentIndex][indexPath.row] objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"MyAppointmentSegueIdentifier" sender:indexPath];
}

#pragma mark - DZNEmptyDatasource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无记录"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MyAppointmentDetailViewController *vc = [segue destinationViewController];
    NSIndexPath *indexPath = sender;
    NSInteger segmentIndex = self.appointSegment.selectedSegmentIndex;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY年MM月dd日"];
    if (0==segmentIndex){
        vc.date = [self.tableData[segmentIndex][indexPath.row] objectForKey:@"times"];
        vc.content = [self.tableData[segmentIndex][indexPath.row] objectForKey:@"notes"];
        NSInteger isaudit = [[self.tableData[segmentIndex][indexPath.row] objectForKey:@"isaudit"] integerValue];
        switch (isaudit) {
            case 0:
                vc.flag = AppointDetailTypeAgreeAndDisagree;
                break;
            case 1:
                vc.flag = AppointDetailTypeAgreed;
                break;
            case 2:
                vc.flag = AppointDetailTypeDisagreed;
                break;
            default:
                break;
        }
        vc.ID = [self.tableData[segmentIndex][indexPath.row] objectForKey:@"id"];
    }
    else{
        NSTimeInterval timestamp = [[self.tableData[segmentIndex][indexPath.row] objectForKey:@"createtime"] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        vc.date = [NSString stringWithFormat:@"时间: %@", [formatter stringFromDate:date]];
        vc.content = [self.tableData[segmentIndex][indexPath.row] objectForKey:@"content"];
        NSInteger flag = [[self.tableData[segmentIndex][indexPath.row] objectForKey:@"flag"] integerValue];
        if (flag == 0)
        {
            NSInteger isaudit = [[self.tableData[segmentIndex][indexPath.row] objectForKey:@"isaudit"] integerValue];
            switch (isaudit){
                case 0:
                    vc.flag = AppointDetailTypeAgreeAndAdd;
                    break;
                case 1:
                    vc.flag = AppointDetailTypeAgreed;
                    break;
                case 2:
                    vc.flag = AppointDetailTypeDisagreed;
                    break;
            }
        }
        else{
            vc.flag = AppointDetailTypeNoButton;
        }
        vc.ID = [self.tableData[segmentIndex][indexPath.row] objectForKey:@"id"];
    }
}


@end
