//
//  ContactPersonalDetailInfoViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/15.
//
//

#import "ContactPersonalDetailInfoViewController.h"
#import <ReactiveCocoa.h>
#import "Friends.h"
@interface ContactPersonalDetailInfoViewController ()
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;
@property (weak, nonatomic) IBOutlet UITextView *describeTextView;

@end

@implementation ContactPersonalDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.noteTextField setText:_currentFriend.noteName];
    [self.describeTextView setText:_currentFriend.situation];
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
@end
