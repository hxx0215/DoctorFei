//
//  MyAppointmentTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/6/15.
//
//

#import "MyAppointmentTableViewController.h"
#import "DoctorAPI.h"

@interface MyAppointmentTableViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *appointSegment;
@property (nonatomic, strong) NSMutableArray *appointmentData;
@property (nonatomic, strong) NSMutableArray *referralData;
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
        NSLog(@"%@",responseObject);
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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyAppointmentIdenty forIndexPath:indexPath];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyAppointmentIdenty];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyAppointmentIdenty];
    }
    
    // Configure the cell...
    if (self.appointSegment.selectedSegmentIndex ==0)
        cell.textLabel.text = @"1234预约";
    else
        cell.textLabel.text = @"1234转诊";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"MyAppointmentSegueIdentifier" sender:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
