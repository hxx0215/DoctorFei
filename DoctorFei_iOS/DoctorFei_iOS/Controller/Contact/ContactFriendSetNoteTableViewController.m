//
//  ContactFriendSetNoteTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import "ContactFriendSetNoteTableViewController.h"
#import "Friends.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
@interface ContactFriendSetNoteTableViewController ()
    <UITextFieldDelegate,UITextViewDelegate>
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *noteLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confrimButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;

@end

@implementation ContactFriendSetNoteTableViewController

@synthesize currentFriend = _currentFriend;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    RAC(self.confrimButton, enabled) = [RACSignal combineLatest:@[self.noteLabel.rac_textSignal] reduce:^(NSString *note){
        return @(note.length > 0);
    }];
    
    
    [self.noteLabel setText:_currentFriend.noteName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.noteLabel becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [self.noteLabel resignFirstResponder];
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
#pragma mark - Actions

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"设置备注中..."];
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"userid": _currentFriend.userId,
                             @"notename": self.noteLabel.text
                             };
    [DoctorAPI setUserNoteWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"设置成功";
            _currentFriend.noteName = self.noteLabel.text;
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

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.textViewBottomConstraint.constant = 250;
    return YES;
}
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.textViewBottomConstraint.constant = 250;
    return YES;
}
@end
