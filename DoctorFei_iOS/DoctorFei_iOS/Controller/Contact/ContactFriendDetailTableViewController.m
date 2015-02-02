//
//  ContactFriendDetailTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import "ContactFriendDetailTableViewController.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
#import "ContactFriendSetNoteTableViewController.h"
#import "ContactFriendSetDescribeTableViewController.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import "Chat.h"
#import "ContactFriendDetailTableViewCell.h"
@interface ContactFriendDetailTableViewController ()

- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *situationLabel;
//@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
//@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (assign, nonatomic) BOOL showTel;
//- (IBAction)phoneButtonClicked:(id)sender;
- (IBAction)deleteFriendButtonClicked:(id)sender;

@end

@implementation ContactFriendDetailTableViewController
@synthesize currentFriend = _currentFriend;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CGRect tableHeaderRect = self.tableView.tableHeaderView.frame;
    tableHeaderRect.size.height = 78.0f;
    [self.tableView.tableHeaderView setFrame:tableHeaderRect];
    
    
    CGRect tableFooterRect = self.tableView.tableFooterView.frame;
    tableFooterRect.size.height = 78.0f;
    [self.tableView.tableFooterView setFrame:tableFooterRect];
    
    self.showTel = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_currentFriend.icon && _currentFriend.icon.length > 0) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_currentFriend.icon] placeholderImage:[UIImage imageNamed:@"details_uers_example_pic"]];
    }
    [self.nameLabel setText:_currentFriend.realname];
//    if (_currentFriend.mobile && _currentFriend.mobile.length > 0) {
//        [self.phoneLabel setText:_currentFriend.mobile];
//        [self.phoneButton setHidden:NO];
//    }
//    else{
//        [self.phoneLabel setText:@""];
//        [self.phoneButton setHidden:YES];
//    }
    [self.noteLabel setText:_currentFriend.noteName];
    [self.situationLabel setText:_currentFriend.situation];
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
    if ([segue.identifier isEqualToString:@"FriendDetailSetNoteSegueIdentifier"]) {
        ContactFriendSetNoteTableViewController *vc = [segue destinationViewController];
        [vc setCurrentFriend:_currentFriend];
    }
    else if ([segue.identifier isEqualToString:@"FriendDetailSetDescribeSegueIdentifier"]) {
        ContactFriendSetDescribeTableViewController *vc = [segue destinationViewController];
        [vc setCurrentFriend:_currentFriend];
    }
}

- (IBAction)phoneButtonClicked:(id)sender {
}

- (IBAction)deleteFriendButtonClicked:(id)sender {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"userid": _currentFriend.userId
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"删除中...";
    [DoctorAPI delFriendWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dict[@"state"]intValue] == 1) {
            hud.labelText = @"删除成功";
            Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
            if (chat) {
                [chat MR_deleteEntity];
            }
            [_currentFriend MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            hud.labelText = @"删除失败";
            hud.detailsLabelText = dict[@"msg"];
        }
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.0f];
    }];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - TableViewDelegate & DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.showTel)
        return 3;
    else
        return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactFriendDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactFriendDetailIdentifier"];
    NSInteger index = indexPath.row;
    switch (index) {
        case 0:
            cell.titleLabel.text = NSLocalizedString(@"性别", nil);
            cell.contentLabel.text = NSLocalizedString(@"男", nil);
            break;
        case 1:
            if (self.showTel){
                cell.titleLabel.text = NSLocalizedString(@"电话", nil);
                cell.contentLabel.text = @"13025064069";
                break;
            }
        case 2:
            cell.titleLabel.text = NSLocalizedString(@"备注及描述", nil);
            cell.contentLabel.text = @"感冒";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ContactFriendDetailTableViewCell *cell = (ContactFriendDetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.showTel && indexPath.row == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",cell.contentLabel.text]]];
    }
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        [self performSegueWithIdentifier:@"FriendDetailSetNoteSegueIdentifier" sender:nil];
    }
}
@end
