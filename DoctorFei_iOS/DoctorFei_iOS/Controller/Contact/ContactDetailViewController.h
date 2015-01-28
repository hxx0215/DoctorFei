//
//  ContactDetailViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//
typedef enum ContactDetailMode{
    ContactDetailModeNormal,
    ContactDetailModeConsultation
} ContactDetailMode;
#import <JSQMessages.h>
@class Friends;

@interface ContactDetailViewController : JSQMessagesViewController

@property (nonatomic, strong) Friends *currentFriend;
@property (nonatomic, assign) ContactDetailMode detailMode;
@end
