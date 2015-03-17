//
//  ContactDetailViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/28.
//
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController.h>
//@class Friends;
@class Chat;

@interface ContactDetailViewController : JSQMessagesViewController

//@property (nonatomic, strong) Friends *currentFriend;
@property (nonatomic, strong) Chat *currentChat;

@end
