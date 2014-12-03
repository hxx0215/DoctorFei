//
//  MyselfIntroInfoEditTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/3.
//
//

#import "MyselfIntroInfoEditTableViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
@interface MyselfIntroInfoEditTableViewController ()

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@end

@implementation MyselfIntroInfoEditTableViewController
@synthesize introValue = _introValue;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.introTextView setTextContainerInset:UIEdgeInsetsZero];
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.introTextView.rac_textSignal] reduce:^(NSString *info){
        return @(info.length > 0);
    }];
    
    [self.introTextView setText:_introValue];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.introTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.introTextView resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)updateInfo {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"提交注册申请中..."];
    NSNumber *currentUserId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSString *currentInfo = [self.introTextView.text copy];
    NSDictionary *params = @{
                             @"doctorid": currentUserId,
                             @"othercontact": currentInfo
                             };
    [DoctorAPI updateInfomationWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"修改成功";
            [[NSUserDefaults standardUserDefaults]setObject:currentInfo forKey:@"UserOtherContact"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            hud.labelText = @"修改错误";
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

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonClicked:(id)sender {
    [self updateInfo];
}
@end
