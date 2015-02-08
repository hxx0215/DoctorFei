//
//  MainGroupNewGroupViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/7.
//
//

#import "MainGroupGroupActionViewController.h"
#import "DoctorAPI.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "Groups.h"
#import "ContactViewController.h"
#import "Friends.h"
@interface MainGroupGroupActionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;

@end

@implementation MainGroupGroupActionViewController
@synthesize currentGroup = _currentGroup;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_currentGroup) {
        self.title = @"修改分组";
        self.nameTextField.text = _currentGroup.title;
    } else {
        self.title = @"新建分组";
    }
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.nameTextField.rac_textSignal] reduce:^(NSString *string) {
        return @(string.length > 0);
    }];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.nameTextField.frame.size.height)];
    leftView.backgroundColor = self.nameTextField.backgroundColor;
    self.nameTextField.leftView = leftView;
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainGroupAddFriendSegueIdentifier"]) {
        ContactViewController *vc = [segue destinationViewController];
        vc.contactMode = ContactViewControllerModeMainGroupAddFriend;
        vc.didSelectFriends = ^(NSArray *selectArray){
            NSLog(@"%@",selectArray);
            //TODO
        };
    }
}

- (void)newGroupRequet {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"新建中...";
    NSNumber *doctorid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorid,
                            @"title": self.nameTextField.text,
                            @"sort": [NSNull null]
                            };
    [DoctorAPI setDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dict = [(NSArray *)responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dict[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([dict[@"state"]intValue] == 1) {
            [self performSegueWithIdentifier:@"MainGroupAddFriendSegueIdentifier" sender:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)updateGroupRequest {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"修改中...";
    NSNumber *doctorid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"doctorid": doctorid,
                            @"groupid": _currentGroup.groupId,
                            @"title": self.nameTextField.text,
                            @"sort": [NSNull null]
                            };
    [DoctorAPI updateDoctorFriendGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = dict[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([dict[@"state"]intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.nameTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonClicked:(id)sender {
    [self.nameTextField resignFirstResponder];
    if (_currentGroup) {
        [self updateGroupRequest];
    }else{
        [self newGroupRequet];
    }
}
@end
