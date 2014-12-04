//
//  ContactDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "ContactDetailViewController.h"
#import "Friends.h"
#import "DeviceUtil.h"
@interface ContactDetailViewController ()
- (IBAction)backButtonClicked:(id)sender;

@end

@implementation ContactDetailViewController
{
    Friends *currentFriend;
}
@synthesize friendId = _friendId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentFriend = [Friends MR_findFirstByAttribute:@"userid" withValue:_friendId];
    if (currentFriend) {
        self.title = currentFriend.realname;
    }
    
    self.senderId = [DeviceUtil getUUID];
    self.senderDisplayName = @"我";
    self.showLoadEarlierMessagesHeader = YES;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
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
@end
