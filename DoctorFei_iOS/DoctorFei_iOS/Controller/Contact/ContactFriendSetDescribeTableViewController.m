//
//  ContactFriendSetDescribeTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/17.
//
//

#import "ContactFriendSetDescribeTableViewController.h"
#import "Friends.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
@interface ContactFriendSetDescribeTableViewController ()
    <UITextFieldDelegate>
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confrimButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
@property (weak, nonatomic) IBOutlet UITextField *describeTextField;

@end

@implementation ContactFriendSetDescribeTableViewController
@synthesize currentFriend = _currentFriend;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.describeTextField.rac_textSignal] reduce:^(NSString *string){
        return @(string.length > 0);
    }];
    
    [self.describeTextField setText:_currentFriend.situation];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.describeTextField becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [self.describeTextField resignFirstResponder];
    [super viewWillAppear:animated];
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

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confrimButtonClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"设置备注中..."];
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"userid": _currentFriend.userId,
                             @"describe": self.describeTextField.text
                             };
    [DoctorAPI setUserDescribeWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"设置成功";
            _currentFriend.situation = self.describeTextField.text;
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            hud.labelText = @"设置失败";
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
@end
