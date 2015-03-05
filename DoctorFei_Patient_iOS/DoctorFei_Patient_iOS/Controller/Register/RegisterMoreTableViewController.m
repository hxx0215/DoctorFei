//
//  RegisterMoreTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/23.
//
//


#import "RegisterMoreTableViewController.h"
#import <IHKeyboardAvoiding.h>
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "MemberAPI.h"
@interface RegisterMoreTableViewController ()
    <UITextFieldDelegate>
- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *hospitalNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *departmentLabel;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextView *introductionTextView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
- (IBAction)confirmButtonClicked:(id)sender;


@end

@implementation RegisterMoreTableViewController
@synthesize userId = _userId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CGRect tableViewFooterFrame = self.tableView.tableFooterView.frame;
    tableViewFooterFrame.size.height = 78.0f;
    [self.tableView.tableFooterView setFrame:tableViewFooterFrame];
    
//    [IHKeyboardAvoiding setAvoidingView:self.confirmButton withTarget:self.introductionTextView];
    
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.nameLabel.rac_textSignal, self.hospitalNameLabel.rac_textSignal, self.departmentLabel.rac_textSignal, self.jobTitleLabel.rac_textSignal, self.emailLabel.rac_textSignal, self.introductionTextView.rac_textSignal] reduce:^(NSString *name, NSString *hospitalName, NSString *department, NSString *jobTitle, NSString *email, NSString *introduction){
        return @(name.length > 0 && hospitalName.length > 0 && department.length > 0 && jobTitle.length > 0 && email.length > 0 && introduction.length > 0);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.nameLabel resignFirstResponder];
    [self.hospitalNameLabel resignFirstResponder];
    [self.departmentLabel resignFirstResponder];
    [self.jobTitleLabel resignFirstResponder];
    [self.emailLabel resignFirstResponder];
    [self.introductionTextView resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (IBAction)backButtonClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:@(_userId) forKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)confirmButtonClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"完善资料中..."];
    NSDictionary *params = @{
                             @"memberid": @(_userId),
                             @"realname": self.nameLabel.text,
                             @"email": self.emailLabel.text,
                             @"hospital": self.hospitalNameLabel.text,
                             @"department": self.departmentLabel.text,
                             @"jobtitle": self.jobTitleLabel.text,
                             @"othercontact": self.introductionTextView.text
                             };
    [MemberAPI updateInfomationWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"完善资料成功";
//            hud.detailsLabelText = dataDict[@"msg"];
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"IsAutoLogin"];
            [[NSUserDefaults standardUserDefaults] setObject:@(_userId) forKey:@"UserId"];
            [[NSUserDefaults standardUserDefaults] setObject:self.nameLabel.text forKey:@"UserRealName"];
            [[NSUserDefaults standardUserDefaults] setObject:self.hospitalNameLabel.text forKey:@"UserHospital"];
            [[NSUserDefaults standardUserDefaults] setObject:self.departmentLabel.text forKey:@"UserDepartment"];
            [[NSUserDefaults standardUserDefaults] setObject:self.jobTitleLabel.text forKey:@"UserJobTitle"];
            [[NSUserDefaults standardUserDefaults] setObject:self.emailLabel.text forKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:self.introductionTextView.text forKey:@"UserOtherContact"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
//            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            hud.labelText = @"完善资料错误";
            hud.detailsLabelText = dataDict[@"msg"];
        }
        [hud hide:YES afterDelay:1.5f];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.nameLabel) {
        [self.hospitalNameLabel becomeFirstResponder];
    }
    else if (textField == self.hospitalNameLabel){
        [self.departmentLabel becomeFirstResponder];
    }
    else if (textField == self.departmentLabel){
        [self.jobTitleLabel becomeFirstResponder];
    }
    else if (textField == self.jobTitleLabel){
        [self.emailLabel becomeFirstResponder];
    }
    else if (textField == self.emailLabel){
        [self.introductionTextView becomeFirstResponder];
    }
    return YES;
}
@end
