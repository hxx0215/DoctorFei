//
//  ContactDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "ContactDetailViewController.h"
#import "Friends.h"
#import "Chat.h"
#import "DeviceUtil.h"
#import "ContactFriendDetailTableViewController.h"
@interface ContactDetailViewController ()
- (IBAction)backButtonClicked:(id)sender;

@end

@implementation ContactDetailViewController
@synthesize currentFriend = _currentFriend;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _currentFriend.realname;
    
    self.senderId = [DeviceUtil getUUID];
    self.senderDisplayName = @"我";
    self.showLoadEarlierMessagesHeader = NO;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
    if (chat) {
        chat.unreadMessageCount = @(0);
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    }
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
        ContactFriendDetailTableViewController *vc = [segue destinationViewController];
        [vc setCurrentFriend:_currentFriend];
    }
}

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Messages view controller

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    
}
@end
