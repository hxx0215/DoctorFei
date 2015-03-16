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
typedef NS_ENUM(NSUInteger, SMSToolbarSendMethod) {
    SMSToolbarSendMethodVoice,
    SMSToolbarSendMethodText
};

@interface ContactDetailViewController ()
    <WYPopoverControllerDelegate, UITextViewDelegate>
- (IBAction)backButtonClicked:(id)sender;
@property (nonatomic, strong) MessagesModalData *modalData;
@property (nonatomic, strong) WYPopoverController *popover;

@end

@implementation ContactDetailViewController
{
    NSArray *messageArray;
    UIButton *voiceButton, *keyboardButton, *faceButton, *pictureButton, *sendVoiceButton;
    MBProgressHUD *voiceHUD;
}

@synthesize currentFriend = _currentFriend;


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

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadMessageData) name:@"NewChatArrivedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteMessage:) name:@"DeleteMessageNotification" object:nil];
    [self cleanUnreadMessageCount];
    if (_currentFriend.noteName && _currentFriend.noteName.length > 0) {
        self.title = _currentFriend.noteName;
    }
    else {
        self.title = _currentFriend.realname;
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
- (void)cleanUnreadMessageCount {
    Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
    if (chat) {
        chat.unreadMessageCount = @(0);
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
    NSString *myName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserRealName"];
    NSString *userSenderId = [_currentFriend.userId stringValue];
    NSString *mySenderId = self.senderId;
    _modalData.messages = [NSMutableArray array];
    
    messageArray = [Message MR_findByAttribute:@"user" withValue:_currentFriend andOrderBy:@"messageId" ascending:YES];
    for (Message *message in messageArray) {
        NSString *senderId, *senderName;
        if ([message.flag intValue] != 0) {
            senderId = userSenderId;
            senderName = _currentFriend.realname;
        }
        else{
            senderId = mySenderId;
            senderName = myName;
        }
        JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:message.createtime text:message.content];
        [_modalData.messages addObject:jsqMessage];
    }
}

- (void)generateMessageModalData {
    _modalData = [[MessagesModalData alloc]init];
    NSString *myName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserRealName"];
    NSString *myIcon = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserIcon"];
    NSString *userSenderId = [_currentFriend.userId stringValue];
    NSString *mySenderId = self.senderId;
    if (myName == nil || [myName isEqualToString:@""]) {
        myName = @"无姓名";
    }
    _modalData.users = @{
                         userSenderId: _currentFriend.realname,
                         mySenderId: myName
                         };
    JSQMessagesAvatarImage *userAvatarImage = [JSQMessagesAvatarImage avatarImageWithPlaceholder:[UIImage imageNamed:@"details_uers_example_pic"]];
    JSQMessagesAvatarImage *myAvatarImage = [JSQMessagesAvatarImage avatarImageWithPlaceholder:[UIImage imageNamed:@"details_uers_example_pic"]];
    //    JSQMessagesAvatarImage *userAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithPlaceholder:[UIImage imageNamed:@"details_uers_example_pic"] diameter:44];
    //    JSQMessagesAvatarImage *myAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithPlaceholder:[UIImage imageNamed:@"details_uers_example_pic"] diameter:44];
    if (_currentFriend.icon && _currentFriend.icon.length > 0) {
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:_currentFriend.icon] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image && finished) {
                [userAvatarImage setAvatarImage:image];
            }
        }];
    }
    if (myIcon && myIcon.length > 0) {
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:myIcon] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image && finished) {
                [myAvatarImage setAvatarImage:image];
            }
        }];
    }
    _modalData.avatars = @{
                           userSenderId: userAvatarImage,
                           mySenderId: myAvatarImage
                           };
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc]init];
    _modalData.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:UIColorFromRGB(0xADE85B)];
    _modalData.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    
    _modalData.messages = [NSMutableArray array];
    
    messageArray = [Message MR_findByAttribute:@"user" withValue:_currentFriend andOrderBy:@"messageId" ascending:YES];
    for (Message *message in messageArray) {
        NSString *senderId, *senderName;
        if ([message.flag intValue] != 0) {
            senderId = userSenderId;
            senderName = _currentFriend.realname;
        }
        else{
            senderId = mySenderId;
            senderName = myName;
        }
        JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:message.createtime text:message.content];
        [_modalData.messages addObject:jsqMessage];
    }
    
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

- (void)sendMessageWithText:(NSString *)text{
    //发送消息
    NSNumber *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"memberid": memberId,
                             @"userid": _currentFriend.userId,
                             @"usertype": _currentFriend.userType,
                             @"msgtype": @"text",
                             @"content": text
                             };
    [MemberAPI sendMessageWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"%@",responseObject);
        NSDictionary *dataDict = [responseObject firstObject];
        if ([dataDict[@"state"]intValue] > -1) {
            JSQMessage *message = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] text:text];
            [self.modalData.messages addObject:message];
            Message *newMessage = [Message MR_createEntity];
            newMessage.messageId = @([dataDict[@"state"]intValue]);
            newMessage.content = text;
            newMessage.createtime = [NSDate date];
            newMessage.flag = @(0);
            newMessage.msgType = @"text";
            newMessage.user = _currentFriend;
            Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
            if (chat == nil) {
                chat = [Chat MR_createEntity];
                chat.user = _currentFriend;
                chat.unreadMessageCount = @(0);
//                [chat.messages setByAddingObject:newMessage];
            }
            chat.lastMessageTime = newMessage.createtime;
            chat.lastMessageContent = newMessage.content;
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            [self.collectionView reloadData];
            //            [self loadNewMessage];
            [self finishSendingMessage];
        }
        else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"发送失败";
            hud.detailsLabelText = dataDict[@"msg"];
            [hud hide:YES afterDelay:1.0f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}


#pragma mark - Button Actions

- (void)sendVoiceButtonTouchDown: (UIButton *)sender {
    voiceHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    voiceHUD.mode = MBProgressHUDModeCustomView;
    voiceHUD.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"talk_pic"]];
    voiceHUD.labelText = @"手指上滑, 取消发送";
    voiceHUD.labelFont = [UIFont systemFontOfSize:14.0f];
    voiceHUD.labelColor = UIColorFromRGB(0xAAAAAA);
}

- (void)sendVoiceButtonTouchUpInside: (UIButton *)sender {
    [voiceHUD hide:YES];
}

- (void)sendVoiceButtonTouchUpOutside: (UIButton *)sender {
    [voiceHUD hide:YES];
}
- (void)voiceButtonClicked:(UIButton *)sender {
    [self setToolbarSendMethod:SMSToolbarSendMethodVoice];
}

- (void)keyboardButtonClicked:(UIButton *)sender {
    [self setToolbarSendMethod:SMSToolbarSendMethodText];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dismissButtonClicked:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)showRecordButtonClicked:(id)sender{
    [self performSegueWithIdentifier:@"ContactShowRecordSegueIdentifier" sender:sender];
}
- (void)showHisPage:(id)sender{
    
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
    if ([segue.identifier isEqualToString:@"ContactDetailActionSegueIdentifier"]){
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
    if ([segue.identifier isEqualToString:@"ContactLaunchAppointmentSegueIdentifier"]){
        ContactLaunchApointmentTableViewController *vc = [segue destinationViewController];
        vc.doctorId = self.currentFriend.userId;
    }
    if ([segue.identifier isEqualToString:@"AgendaTimeScheduleSegueIdentifier"]){
        AgendaTimeScheduleViewController *vc = [segue destinationViewController];
        vc.doctorId = self.currentFriend.userId;
    }
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
    
    //    JSQMessage *message = self.modalData.messages[indexPath.item];
    cell.textView.textColor = [UIColor blackColor];
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    cell.backgroundColor =[UIColor clearColor];
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
        [self performSegueWithIdentifier:@"FriendDetailSegueIdentifier" sender:nil];
    }
    //    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
