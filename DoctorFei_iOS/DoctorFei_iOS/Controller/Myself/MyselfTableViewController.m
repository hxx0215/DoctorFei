//
//  MyselfTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#define kMyselfInfoNameArray @[@"头像", @"姓名", @"医院", @"科室", @"职称", @"邮箱"]
#define kMyselfInfoKeyArray @[@"headimage", @"realname", @"hospital", @"department", @"jobtitle", @"email"]
#import "MyselfTableViewController.h"
#import "MySelfBasicInfoEditTableViewController.h"
#import "MyselfIntroInfoEditTableViewController.h"

@interface MyselfTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmengLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextView *introductionTextView;
//@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;


@end

@implementation MyselfTableViewController
{
    NSArray *basicInfoArray;
    NSString *icon, *name, *hospital, *department, *jobTitle, *email, *introduction;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.introductionTextView setTextContainerInset:UIEdgeInsetsZero];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    icon = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserIcon"] copy];
    name = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"] copy];
    hospital = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserHospital"] copy];
    department = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserDepartment"] copy];
    jobTitle = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserJobTitle"] copy];
    email = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserEmail"] copy];
    introduction = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserOtherContact"]copy];
    basicInfoArray = @[icon, name, hospital, department, jobTitle, email];
    
    //TODO 头像未处理
    [self.nameLabel setText:name];
    [self.hospitalNameLabel setText:hospital];
    [self.departmengLabel setText:department];
    [self.jobTitleLabel setText:jobTitle];
    [self.emailLabel setText:email];
    [self.introductionTextView setText:introduction];

//    [self.introductionLabel setText:introduction];
//    [self.introductionLabel sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([segue.identifier isEqualToString:@"MyselfBasicInfoEditSegueIdentifier"]) {
        MySelfBasicInfoEditTableViewController *vc = [segue destinationViewController];
        [vc setName:kMyselfInfoNameArray[indexPath.row]];
        [vc setKey:kMyselfInfoKeyArray[indexPath.row]];
        [vc setValue:basicInfoArray[indexPath.row]];
    }
    else if ([segue.identifier isEqualToString:@"MyselfIntroInfoEditSegueIdentifier"]) {
        MyselfIntroInfoEditTableViewController *vc = [segue destinationViewController];
        [vc setIntroValue:introduction];
    }
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row != 0) {
        [self performSegueWithIdentifier:@"MyselfBasicInfoEditSegueIdentifier" sender:nil];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"MyselfIntroInfoEditSegueIdentifier" sender:nil];
    }
}
@end
