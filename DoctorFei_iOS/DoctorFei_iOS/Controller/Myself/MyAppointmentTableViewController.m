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

@interface MyAppointmentTableViewController ()
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
    headFrame.size.height = 28;
    self.tableView.tableHeaderView.frame = headFrame;
    self.tableData = [[NSMutableArray alloc] initWithCapacity:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)refreshData{
    NSDictionary *params = @{@"doctorid": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]};
    [DoctorAPI getAppointmentWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"appointment:%@",responseObject);
        self.tableData[0] = responseObject;
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",error);
    }];
    [DoctorAPI getReferralInfoWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"referral:%@",responseObject);
        self.tableData[1] = responseObject;
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
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    }
    else{
        NSTimeInterval timestamp = [[self.tableData[segmentIndex][indexPath.row] objectForKey:@"createtime"] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        vc.date = [formatter stringFromDate:date];
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
    }
}


@end
