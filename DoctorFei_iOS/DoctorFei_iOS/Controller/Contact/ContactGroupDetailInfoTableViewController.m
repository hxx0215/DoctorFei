//
//  ContactGroupDetailInfoTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/29.
//
//

#import "ContactGroupDetailInfoTableViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "ChatAPI.h"
#import "GroupChat.h"
@interface ContactGroupDetailInfoTableViewController ()
    <UITextFieldDelegate, UITableViewDelegate>
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *infoTextField;

@end

@implementation ContactGroupDetailInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[_infoTextField.rac_textSignal] reduce:^(NSString *info){
        return @(info.length > 0);
    }];
    [self.infoTextField setText:_groupChat.name];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.infoTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.infoTextField resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateInfo {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSString *currentInfo = [self.infoTextField.text copy];
    NSDictionary *params = @{
                             @"groupid": _groupChat.groupId,
                             @"name": currentInfo
                             };
    [ChatAPI updateChatGroupWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"修改成功";
            _groupChat.name = currentInfo;
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
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

- (IBAction)confirmButtonClicked:(id)sender {
    [self updateInfo];
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        [self updateInfo];
    }
    return YES;
}


#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

@end
