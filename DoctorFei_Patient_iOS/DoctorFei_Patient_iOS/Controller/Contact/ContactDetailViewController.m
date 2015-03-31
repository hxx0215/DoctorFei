//
//  ContactDetailViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/28.
//
//

#import "ContactDetailViewController.h"
#import "Friends.h"
#import <WYStoryboardPopoverSegue.h>
#import "MessagesModalData.h"
#import <MBProgressHUD.h>
#import <Masonry.h>
#import "DeviceUtil.h"
#import <SDWebImageManager.h>
#import "Message.h"
#import "Chat.h"
#import "MemberAPI.h"
#import "ContactDetailPopoverViewController.h"
#import "DoctorFei_Patient_iOS-swift.h"
#import "ContactDoctorFriendDetailTableViewController.h"
#import "ContactPeronsalFriendDetailTableViewController.h"
#import "JSQAudioMediaItem.h"
#import "RecordAudio.h"
#import "ImageUtil.h"
#import "ImageDetailViewController.h"
#import "JSQAudioMediaItem.h"
#import "ChatAPI.h"
#import "ContactGroupDetailUserTableViewController.h"

typedef NS_ENUM(NSUInteger, SMSToolbarSendMethod) {
    SMSToolbarSendMethodVoice,
    SMSToolbarSendMethodText
};

@interface ContactDetailViewController ()
    <WYPopoverControllerDelegate, UITextViewDelegate, RecordAudioDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)backButtonClicked:(id)sender;
@property (nonatomic, strong) MessagesModalData *modalData;
@property (nonatomic, strong) WYPopoverController *popover;

@end

@implementation ContactDetailViewController
{
    NSArray *messageArray;
    UIButton *voiceButton, *keyboardButton, *faceButton, *pictureButton, *sendVoiceButton;
    MBProgressHUD *voiceHUD;
    RecordAudio *recordAudio;
    NSData *currentRecordData;
    double startRecordTime, endRecordTime;
    JSQAudioMediaItem *currentPlayItem;
    UIBarButtonItem *groupUserButtonItem;
}

//@synthesize currentFriend = _currentFriend;
@synthesize currentChat = _currentChat;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupToolbarButtons];
    //设置ToolBar按钮
    self.inputToolbar.contentView.leftBarButtonItem = voiceButton;
    self.inputToolbar.contentView.rightBarButtonItem = nil;
    UIView *rightView = self.inputToolbar.contentView.rightBarButtonContainerView;
    rightView.hidden = NO;
    [rightView addSubview:faceButton];
    [rightView addSubview:pictureButton];
    
    [faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rightView).with.offset(0);
        make.bottom.equalTo(rightView).with.offset(0);
        make.left.equalTo(rightView).with.offset(0);
    }];
    [pictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rightView).with.offset(0);
        make.bottom.equalTo(rightView).with.offset(0);
        make.right.equalTo(rightView).with.offset(-6);
    }];
    self.inputToolbar.contentView.rightBarButtonItemWidth = 76;
    
    //    [self.inputToolbar.contentView.rightBarButtonContainerView addSubview:faceButton];
    self.collectionView.backgroundColor = UIColorFromRGB(0xEEEEEE);
    
    self.senderId = [[DeviceUtil getUUID]copy];
    self.senderDisplayName = @"我";
    self.showLoadEarlierMessagesHeader = NO;
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    //    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.collectionView.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 15, 5, 15);
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(44, 44);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(44, 44);
    
    [self generateMessageModalData];
    
    self.inputToolbar.contentView.textView.returnKeyType = UIReturnKeySend;
    self.inputToolbar.contentView.textView.delegate = self;
    
    recordAudio = [[RecordAudio alloc]init];
    recordAudio.delegate = self;


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadMessageData) name:@"NewChatArrivedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteMessage:) name:@"DeleteMessageNotification" object:nil];
    [self cleanUnreadMessageCount];
    if (_currentChat.type.intValue < 3){
        Friends *currentFriend = _currentChat.user.allObjects.firstObject;
        if (currentFriend.noteName && currentFriend.noteName.length > 0) {
            self.title = currentFriend.noteName;
        }
        else {
            self.title = currentFriend.realname;
        }
    }else if (_currentChat.type.intValue == 3){
        self.title = _currentChat.title;
        groupUserButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"group-data_btn"] style:UIBarButtonItemStyleBordered target:self action:@selector(groupUserButtonItemClicked:)];
        [groupUserButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationItem setRightBarButtonItem:groupUserButtonItem];
    }else{
        self.title = _currentChat.title;
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    sendVoiceButton.frame = self.inputToolbar.contentView.textView.frame;
    [sendVoiceButton addConstraints:self.inputToolbar.contentView.textView.constraints];
    [self.inputToolbar.contentView addSubview:sendVoiceButton];
    
    [self setToolbarSendMethod:SMSToolbarSendMethodText];

}

- (void)setupToolbarButtons {
    voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [voiceButton setImage:[UIImage imageNamed:@"voice_btn"] forState:UIControlStateNormal];
    [voiceButton setImage:[UIImage imageNamed:@"voice_btn_after"] forState:UIControlStateHighlighted];
    [voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [keyboardButton setImage:[UIImage imageNamed:@"keyboard_btn"] forState:UIControlStateNormal];
    [keyboardButton addTarget:self action:@selector(keyboardButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [faceButton setImage:[UIImage imageNamed:@"face_btn"] forState:UIControlStateNormal];
    [faceButton setImage:[UIImage imageNamed:@"face_btn_after"] forState:UIControlStateHighlighted];
    
    pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pictureButton setImage:[UIImage imageNamed:@"imange_btn"] forState:UIControlStateNormal];
    [pictureButton setImage:[UIImage imageNamed:@"imange_btn_after"] forState:UIControlStateHighlighted];
    [pictureButton addTarget:self action:@selector(pictureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    sendVoiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendVoiceButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [sendVoiceButton setBackgroundImage:[[UIImage imageNamed:@"talk_box_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 8, 4, 8)] forState:UIControlStateNormal];
    [sendVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [sendVoiceButton setTitleColor:UIColorFromRGB(0x474747) forState:UIControlStateNormal];
    [sendVoiceButton setBackgroundImage:[[UIImage imageNamed:@"talk_box_btn_after"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 8, 4, 8)] forState:UIControlStateHighlighted];
    [sendVoiceButton setTitleColor:UIColorFromRGB(0x969696) forState:UIControlStateHighlighted];
    [sendVoiceButton setTitle:@"松开结束" forState:UIControlStateHighlighted];
    
    [sendVoiceButton addTarget:self action:@selector(sendVoiceButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [sendVoiceButton addTarget:self action:@selector(sendVoiceButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [sendVoiceButton addTarget:self action:@selector(sendVoiceButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)setToolbarSendMethod:(SMSToolbarSendMethod)method {
    if (method == SMSToolbarSendMethodText) {
        self.inputToolbar.contentView.leftBarButtonItem = voiceButton;
        [sendVoiceButton setHidden:YES];
        [self.inputToolbar.contentView.textView setHidden:NO];
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    } else if (method == SMSToolbarSendMethodVoice){
        self.inputToolbar.contentView.leftBarButtonItem = keyboardButton;
        [self.inputToolbar.contentView.textView resignFirstResponder];
        [self.inputToolbar.contentView.textView setHidden:YES];
        [sendVoiceButton setHidden:NO];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
//    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
}

#pragma mark - Actions
- (void)groupUserButtonItemClicked:(id)sender {
    [self performSegueWithIdentifier:@"ContactGroupDetailUserSegueIdentifier" sender:nil];
}

- (void)cleanUnreadMessageCount {
//    Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
    if ([_currentChat.unreadMessageCount intValue] > 0) {
        _currentChat.unreadMessageCount = @(0);
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    }
}

- (void)reloadMessageData {
    [self cleanUnreadMessageCount];
    [self refreshMessageModal];
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
}
- (void)refreshMessageModal {
    _modalData.messages = [NSMutableArray array];
    NSString *myName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserRealName"];
    NSString *mySenderId = self.senderId;
    messageArray = [Message MR_findByAttribute:@"chat" withValue:_currentChat andOrderBy:@"messageId" ascending:YES];
    for (Message *message in messageArray) {
        NSString *senderId, *senderName;
//        if ([message.flag intValue] != 0) {
        if (message.user != nil) {
            senderId = [NSString stringWithFormat:@"%@;%@",[message.user.userId stringValue],[message.user.userType stringValue]];
            senderName = message.user.realname;
        }
        else{
            senderId = mySenderId;
            senderName = myName;
        }
        JSQMessage *jsqMessage;
        if ([message.msgType isEqualToString:kSendMessageTypeText]) {
            jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:message.createtime text:message.content];
        }else if([message.msgType isEqualToString:kSendMessageTypeImage]) {
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc]initWithImage:nil];
            if (message.user != nil) {
                photoItem.appliesMediaViewMaskAsOutgoing = NO;
            }
            jsqMessage = [[JSQMessage alloc]initWithSenderId:senderId senderDisplayName:senderName date:message.createtime media:photoItem];
            [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:message.content] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image && finished) {
                    photoItem.image = image;
                    [self.collectionView reloadData];
                }
            }];
        }else if ([message.msgType isEqualToString:kSendMessageTypeAudio]) {
            JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc]initWithFileURL:[NSURL URLWithString:message.content] isReadyToPlay:YES];
            if (message.user != nil) {
                audioItem.appliesMediaViewMaskAsOutgoing = NO;
            }
            jsqMessage = [[JSQMessage alloc]initWithSenderId:senderId senderDisplayName:senderName date:[NSDate date] media:audioItem];
        }
        [_modalData.messages addObject:jsqMessage];
    }

}

- (void)generateMessageModalData {
    _modalData = [[MessagesModalData alloc]init];
    NSString *myName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserRealName"];
    NSString *myIcon = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserIcon"];
//    NSString *userSenderId = [_currentFriend.userId stringValue];
    NSString *mySenderId = self.senderId;
    if (myName == nil || [myName isEqualToString:@""]) {
        myName = @"无姓名";
    }
    NSMutableDictionary  *avatarDict, *nameDict;
    avatarDict = [NSMutableDictionary dictionary];
    nameDict = [NSMutableDictionary dictionary];
    [nameDict setObject:myName forKey:mySenderId];
    JSQMessagesAvatarImage *myAvatarImage = [JSQMessagesAvatarImage avatarImageWithPlaceholder:[UIImage imageNamed:@"details_uers_example_pic"]];
    if (myIcon && myIcon.length > 0) {
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:myIcon] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image && finished) {
                [myAvatarImage setAvatarImage:image];
            }
        }];
    }
    [avatarDict setObject:myAvatarImage forKey:mySenderId];
    
    for (Friends *friend in _currentChat.user) {
        NSString *userSenderId = [NSString stringWithFormat:@"%@;%@",[friend.userId stringValue],[friend.userType stringValue]];
        JSQMessagesAvatarImage *userAvatarImage = [JSQMessagesAvatarImage avatarImageWithPlaceholder:[UIImage imageNamed:@"details_uers_example_pic"]];
        if (friend.icon && friend.icon.length > 0) {
            [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:friend.icon] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image && finished) {
                    [userAvatarImage setAvatarImage:image];
                }
            }];
        }
        [nameDict setObject:friend.realname forKey:userSenderId];
        [avatarDict setObject:userAvatarImage forKey:userSenderId];
    }
    
    _modalData.avatars = avatarDict;
    _modalData.users = nameDict;

    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc]init];
    _modalData.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:UIColorFromRGB(0xADE85B)];
    _modalData.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self refreshMessageModal];
}

- (void)deleteMessage:(NSNotification *)notification {
    JSQMessagesCollectionViewCell *cell = notification.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    //    NSLog(@"%@",indexPath);
    Message *message = messageArray[indexPath.row];
    [message MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    [self.modalData.messages removeObjectAtIndex:indexPath.row];
    //    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self.collectionView reloadData];
}
- (void)saveMessageWithMessageId:(NSNumber *)messageId type:(NSString *)type andContent:(NSString *)content{
    JSQMessage *message;
    if ([type isEqualToString:kSendMessageTypeText]) {
        message = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] text:content];
    }else if ([type isEqualToString:kSendMessageTypeImage]) {
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc]initWithImage:nil];
        message = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:photoItem];
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:content] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (image && finished) {
                photoItem.image = image;
                [self.collectionView reloadData];
            }
        }];
    }else if ([type isEqualToString:kSendMessageTypeAudio]) {
        JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc]initWithFileURL:[NSURL URLWithString:content] isReadyToPlay:YES];
        message = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:audioItem];
    }
    [self.modalData.messages addObject:message];
    Message *newMessage = [Message MR_createEntity];
    newMessage.messageId = messageId ;
    newMessage.content = content;
    newMessage.createtime = [NSDate date];
    newMessage.flag = @(0);
    newMessage.msgType = type;
    newMessage.user = nil;
    newMessage.chat = _currentChat;
    _currentChat.unreadMessageCount = @0;
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    [self.collectionView reloadData];
    [self finishSendingMessage];
    
}

- (void)sendMessageWithContent:(NSString *)content andType:(NSString *)type{
    if (_currentChat.type.intValue < 3) {
        NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
        NSDictionary *params = @{
                                 @"memberid": memberId,
                                 @"userid": [_currentChat.user.allObjects.firstObject userId],
                                 @"usertype": [_currentChat.user.allObjects.firstObject userType],
                                 @"msgtype": type,
                                 @"content": content
                                 };
        [MemberAPI sendMessageWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dataDict = [responseObject firstObject];
            if ([dataDict[@"state"]intValue] > -1) {
                [self saveMessageWithMessageId:@([dataDict[@"state"] intValue]) type:type andContent:content];
            }
            else{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"发送失败";
                hud.detailsLabelText = dataDict[@"msg"];
                [hud hide:YES afterDelay:1.5f];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"发送失败";
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.5f];
        }];
    }else if (_currentChat.type.intValue == 4) {
        NSDictionary *param = @{
                                @"groupid": _currentChat.chatId,
                                @"userid": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],
                                @"usertype": @0,
                                @"msgtype": type,
                                @"contents": content
                                };
        [ChatAPI sendTempGroupMessageWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dataDict = [responseObject firstObject];
            if ([dataDict[@"curid"]intValue] > 0) {
                [self saveMessageWithMessageId:@([dataDict[@"curid"]intValue]) type:type andContent:content];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"发送失败";
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.5f];
        }];

    }else if (_currentChat.type.intValue == 3) {
        NSDictionary *param = @{
                                @"groupid": _currentChat.chatId,
                                @"userid": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"],
                                @"usertype": @0,
                                @"msgtype": type,
                                @"contents": content
                                };
        [ChatAPI setChatNoteWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *result = [responseObject firstObject];
            if ([result[@"curid"] intValue] != 0) {
                [self saveMessageWithMessageId:@([result[@"curid"] intValue]) type:type andContent:content];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"发送失败";
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.5f];
        }];
    }
    
}

- (void)sendMessageWithText:(NSString *)text{
    //发送消息
    [self sendMessageWithContent:text andType:kSendMessageTypeText];
//    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
//    NSDictionary *params = @{
//                             @"memberid": memberId,
//                             @"userid": _currentFriend.userId,
//                             @"usertype": _currentFriend.userType,
//                             @"msgtype": @"text",
//                             @"content": text
//                             };
//    [MemberAPI sendMessageWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //        NSLog(@"%@",responseObject);
//        NSDictionary *dataDict = [responseObject firstObject];
//        if ([dataDict[@"state"]intValue] > -1) {
//            JSQMessage *message = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] text:text];
//            [self.modalData.messages addObject:message];
//            Message *newMessage = [Message MR_createEntity];
//            newMessage.messageId = @([dataDict[@"state"]intValue]);
//            newMessage.content = text;
//            newMessage.createtime = [NSDate date];
//            newMessage.flag = @(0);
//            newMessage.msgType = @"text";
//            newMessage.user = _currentFriend;
//            Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
//            if (chat == nil) {
//                chat = [Chat MR_createEntity];
//                chat.user = _currentFriend;
//                chat.unreadMessageCount = @(0);
////                [chat.messages setByAddingObject:newMessage];
//            }
//            chat.lastMessageTime = newMessage.createtime;
//            chat.lastMessageContent = newMessage.content;
//            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
//            [self.collectionView reloadData];
//            //            [self loadNewMessage];
//            [self finishSendingMessage];
//        }
//        else {
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = @"发送失败";
//            hud.detailsLabelText = dataDict[@"msg"];
//            [hud hide:YES afterDelay:1.0f];
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error.localizedDescription);
//    }];
}


#pragma mark - Button Actions

- (void)sendVoiceButtonTouchDown: (UIButton *)sender {
    voiceHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    voiceHUD.mode = MBProgressHUDModeCustomView;
    voiceHUD.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"talk_pic"]];
    voiceHUD.labelText = @"手指上滑, 取消发送";
    voiceHUD.labelFont = [UIFont systemFontOfSize:14.0f];
    voiceHUD.labelColor = UIColorFromRGB(0xAAAAAA);
    
    [recordAudio stopPlay];
    [recordAudio startRecord];
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    currentRecordData = nil;
}

- (void)sendVoiceButtonTouchUpInside: (UIButton *)sender {
    [voiceHUD hide:YES];
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    endRecordTime -= startRecordTime;
    if (endRecordTime<2.00f) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"录音时间过短";
        [hud hide:YES afterDelay:1.0f];
        return;
    } else if (endRecordTime>60.00f){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"录音时间过长";
        [hud hide:YES afterDelay:1.0f];
        return;
    }
    NSURL *url = [recordAudio stopRecord];
    if (url != nil) {
        currentRecordData = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url], 1, 16);
        [ChatAPI uploadAudio:@".amr" dataStream:currentRecordData success:^(NSURLResponse *operation, id responseObject) {
            NSLog(@"%@",responseObject);
            NSDictionary *result = [responseObject firstObject];
            if ([result[@"state"] intValue] == 1) {
                NSString *urlString = result[@"spath"];
                if (urlString.length > 0) {
                    [self sendMessageWithContent:urlString andType:kSendMessageTypeAudio];
                }
            }
        } failure:^(NSURLResponse *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }

}

- (void)sendVoiceButtonTouchUpOutside: (UIButton *)sender {
    [voiceHUD hide:YES];
    [recordAudio stopRecord];
}
- (void)voiceButtonClicked:(UIButton *)sender {
    [self setToolbarSendMethod:SMSToolbarSendMethodVoice];
}

- (void)keyboardButtonClicked:(UIButton *)sender {
    [self setToolbarSendMethod:SMSToolbarSendMethodText];
}
- (void)pictureButtonClicked:(id)sender{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", nil];
    }
    sheet.tag = 255;
    [sheet showFromTabBar:self.tabBarController.tabBar];
    
}

- (IBAction)backButtonClicked:(id)sender {
    if (_currentChat.messages.count == 0) {
        [_currentChat MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dismissButtonClicked:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)showRecordButtonClicked:(id)sender{
    [self performSegueWithIdentifier:@"ContactShowRecordSegueIdentifier" sender:sender];
}
- (void)showHisPage:(id)sender{
    [self performSegueWithIdentifier:@"HisPageSegueIdentifier" sender:sender];
}
- (void)departTime:(id)sender{
    [self performSegueWithIdentifier:@"AgendaTimeScheduleSegueIdentifier" sender:sender];
}
- (void)launchAppointment:(id)sender{
    [self performSegueWithIdentifier:@"ContactLaunchAppointmentSegueIdentifier" sender:sender];
    NSLog(@"launch");
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactDetailDoctorSegueIdentifier"]) {
        Friends *friend = (Friends *)sender;
        ContactDoctorFriendDetailTableViewController *vc = [segue destinationViewController];
        [vc setCurrentFriend:friend];
        [vc setMode:ContactDoctorFriendDetailModeNormal];
    }else if ([segue.identifier isEqualToString:@"ContactDetailMemberSegueIdentifier"]) {
        Friends *friend = (Friends *)sender;
        ContactPeronsalFriendDetailTableViewController *vc = [segue destinationViewController];
        [vc setCurrentFriend:friend];
        [vc setMode:ContactPersonalFriendDetailModeNormal];
    }
    else if ([segue.identifier isEqualToString:@"ContactDetailActionSegueIdentifier"]){
        ContactDetailPopoverViewController *vc = [segue destinationViewController];
        vc.preferredContentSize = CGSizeMake(120, 122);
        vc.showHisPage = @selector(showHisPage:);
        vc.launchAppointment = @selector(launchAppointment:);
        vc.departTime = @selector(departTime:);
        vc.target = self;
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        
        self.popover = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        self.popover.delegate = self;
        self.popover.dismissOnTap = YES;
        self.popover.theme.outerCornerRadius = 0;
        self.popover.theme.innerCornerRadius = 0;
        self.popover.theme.fillTopColor = [UIColor darkGrayColor];
        self.popover.theme.fillBottomColor = [UIColor darkGrayColor];
        self.popover.theme.arrowHeight = 8.0f;
        self.popover.popoverLayoutMargins = UIEdgeInsetsZero;
    }
    else if ([segue.identifier isEqualToString:@"ContactLaunchAppointmentSegueIdentifier"]){
        ContactLaunchApointmentTableViewController *vc = [segue destinationViewController];
        Friends *currentFriend = _currentChat.user.allObjects.firstObject;
        vc.doctorId = currentFriend.userId;
    }
    else if ([segue.identifier isEqualToString:@"AgendaTimeScheduleSegueIdentifier"]){
        AgendaTimeScheduleViewController *vc = [segue destinationViewController];
        Friends *currentFriend = _currentChat.user.allObjects.firstObject;
        vc.doctorId = currentFriend.userId;
    }
    else if ([segue.identifier isEqualToString:@"HisPageSegueIdentifier"]){
        HisPageViewController *vc = [segue destinationViewController];
        vc.doctor = _currentChat.user.allObjects.firstObject;
    }
    else if ([segue.identifier isEqualToString:@"ImageDetailSegueIdentifier"]) {
        ImageDetailViewController *vc = [segue destinationViewController];
        [vc setImage:sender];
    }
    else if ([segue.identifier isEqualToString:@"ContactGroupDetailUserSegueIdentifier"]) {
        ContactGroupDetailUserTableViewController *vc = [segue destinationViewController];
        [vc setCurrentGroupChat:_currentChat.groupChat];
    }

}

#pragma mark - RecordAudioDelegate
-(void)RecordStatus:(int)status {
    if (status==0){
        //播放中
    } else if(status==1){
        //完成
        NSLog(@"播放完成");
        [currentPlayItem endPlaySound];
        currentPlayItem = nil;
    }else if(status==2){
        //出错
        NSLog(@"播放出错");
    }
    
}

#pragma mark - UIActionSheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = 0;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                default:
                    return;
            }
        }
        else {
            if (buttonIndex == 1) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
        }
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}
#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        if(image)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"上传中...";
            UIImage *cropImage = [ImageUtil imageResizeToRetinaScreenSizeWithImage:image];
            [MemberAPI uploadImage:cropImage success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *result = [responseObject firstObject];
                NSString *urlString = result[@"spath"];
                if (urlString.length > 0) {
                    [[SDImageCache sharedImageCache]storeImage:cropImage forKey:urlString toDisk:YES];
                    [self sendMessageWithContent:urlString andType:kSendMessageTypeImage];
                    [hud hide:YES];
                }else{
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"图片上传失败";
                    //                    hud.detailsLabelText = dataDict[@"msg"];
                    [hud hide:YES afterDelay:1.0f];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = error.localizedDescription;
                [hud hide:YES afterDelay:1.5f];
                NSLog(@"%@",error.localizedDescription);
            }];
        }
    }];

}


#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        if (textView.text.length > 0) {
            [textView resignFirstResponder];
            [self sendMessageWithText:textView.text];
        }
        return NO;
    }
    return YES;
}

#pragma mark - JSQMessages CollectionView DataSource
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.modalData.messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = self.modalData.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.modalData.outgoingBubbleImageData;
    }
    return self.modalData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = self.modalData.messages[indexPath.item];
    return self.modalData.avatars[message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = self.modalData.messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = self.modalData.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = self.modalData.messages[indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.modalData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = self.modalData.messages[indexPath.item];
    if (!message.isMediaMessage) {
        cell.textView.textColor = [UIColor blackColor];
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
        cell.backgroundColor =[UIColor clearColor];
    }
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = self.modalData.messages[indexPath.item];
    if ([[currentMessage senderId]isEqualToString:self.senderId]) {
        return 0.0f;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = self.modalData.messages[indexPath.item - 1];
        if ([[previousMessage senderId]isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = self.modalData.messages[indexPath.item];
    if (![[currentMessage senderId]isEqualToString:self.senderId]) {
        NSString *userSenderId = currentMessage.senderId;
        NSArray *array = [userSenderId componentsSeparatedByString:@";"];
        NSNumber *userId = @([array[0]intValue]);
        NSNumber *userType = @([array[1]intValue]);
        Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ AND userType == %@", userId, userType]];
        if (userType.intValue == 2) {
            [self performSegueWithIdentifier:@"ContactDetailDoctorSegueIdentifier" sender:friend];
        }else{
            [self performSegueWithIdentifier:@"ContactDetailMemberSegueIdentifier" sender:friend];
        }
        //        [self performSegueWithIdentifier:@"FriendDetailSegueIdentifier" sender:nil];
    }
    //    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    JSQMessage *currentMessage = self.modalData.messages[indexPath.item];
    if (currentMessage.isMediaMessage) {
        if ([currentMessage.media isKindOfClass:[JSQPhotoMediaItem class]]) {
            [self performSegueWithIdentifier:@"ImageDetailSegueIdentifier" sender:((JSQPhotoMediaItem *)currentMessage.media).image];
        }else if ([currentMessage.media isKindOfClass:[JSQAudioMediaItem class]]) {
            JSQAudioMediaItem *item = (JSQAudioMediaItem *)currentMessage.media;
            if (currentPlayItem != item) {
                [recordAudio stopPlay];
                [item startPlaySound];
                [recordAudio play:[NSData dataWithContentsOfURL:item.fileURL]];
                currentPlayItem = item;
                
            }else{
                [recordAudio stopPlay];
            }
        }
    }

}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
