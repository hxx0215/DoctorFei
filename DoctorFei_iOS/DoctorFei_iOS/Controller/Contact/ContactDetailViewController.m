//
//  ContactDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "ContactDetailViewController.h"
#import "Message.h"
#import "Friends.h"
#import "Chat.h"
#import "DeviceUtil.h"
#import "ContactFriendDetailTableViewController.h"
#import "MessagesModalData.h"
#import <SDWebImageManager.h>
#import "ChatAPI.h"
#import <MBProgressHUD.h>
//#import "DataUtil.h"
@interface ContactDetailViewController ()
- (IBAction)backButtonClicked:(id)sender;
@property (nonatomic, strong) MessagesModalData *modalData;
@end

@implementation ContactDetailViewController
{
    NSArray *messageArray;
}
@synthesize currentFriend = _currentFriend, modalData = _modalData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    self.collectionView.backgroundColor = UIColorFromRGB(0xEEEEEE);
    
    self.senderId = [[DeviceUtil getUUID]copy];
    self.senderDisplayName = @"我";
    self.showLoadEarlierMessagesHeader = NO;
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.collectionView.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 15, 5, 15);
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(44, 44);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(44, 44);
    
    [self generateMessageModalData];


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

- (void)deleteMessage:(NSNotification *)notification {
    JSQMessagesCollectionViewCell *cell = notification.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSLog(@"%@",indexPath);
    Message *message = messageArray[indexPath.row];
    [message MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    [self.modalData.messages removeObjectAtIndex:indexPath.row];
//    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUnreadMessageCount {
    Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
    if (chat) {
        chat.unreadMessageCount = @(0);
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    }
}

- (void)reloadMessageData {
    [self cleanUnreadMessageCount];
    [self generateMessageModalData];
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)generateMessageModalData {
    _modalData = [[MessagesModalData alloc]init];
    NSString *myName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserRealName"];
    NSString *myIcon = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserIcon"];
    NSString *userSenderId = [_currentFriend.userId stringValue];
    NSString *mySenderId = self.senderId;
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
        if ([message.flag intValue] == 0) {
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

- (void)loadNewMessage {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
//    NSArray *messageArray = [Message MR_findByAttribute:@"user" withValue:_currentFriend andOrderBy:@"messageId" ascending:YES];
    Message *message = [messageArray lastObject];
//    if ([lastDate isEqual:[NSNull null]]){
//        lastDate = [NSDate dateWithTimeIntervalSinceNow:-86400];
//    }
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"userid": _currentFriend.userId,
                             @"times": @((int)message.createtime.timeIntervalSince1970)
                             };
    NSLog(@"%@",params);
    [ChatAPI getChatWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *receiveMessageArray = (NSArray *)responseObject;
        for (NSDictionary *dict in receiveMessageArray) {
            Message *message = [Message MR_findFirstByAttribute:@"messageId" withValue:dict[@"id"]];
            if (message == nil) {
                message = [Message MR_createEntity];
                message.messageId = dict[@"id"];
            }
            message.content = dict[@"content"];
            message.createtime = [NSDate dateWithTimeIntervalSince1970:[dict[@"createtime"]intValue]];
//            message.createtime = [DataUtil dateaFromFormatedString:dict[@"createtime"]];
            message.flag = @([dict[@"flag"]intValue]);
            message.msgType = dict[@"msgtype"];
            message.user = _currentFriend;
        }
        //        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
        if (chat == nil) {
            chat = [Chat MR_createEntity];
            chat.user = _currentFriend;
        }
        chat.unreadMessageCount = @([params[@"total"]intValue]);
        Message *message = [[Message MR_findByAttribute:@"user" withValue:_currentFriend andOrderBy:@"messageId" ascending:YES]lastObject];
        chat.lastMessageTime = message.createtime;
        chat.lastMessageContent = message.content;
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        //发送通知通知刷新MainVC
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NewChatArrivedNotification" object:nil];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FriendDetailSegueIdentifier"]) {
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
    //TODO 发送消息
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"userid": _currentFriend.userId,
                             @"msgtype": @"text",
                             @"content": text
                             };
    NSLog(@"%@",params);
    [ChatAPI sendMessageWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dataDict = [responseObject firstObject];
        if ([dataDict[@"state"]intValue] != -1) {
            JSQMessage *message = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] text:text];
            [self.modalData.messages addObject:message];
            Message *newMessage = [Message MR_createEntity];
            newMessage.messageId = @([dataDict[@"state"]intValue]);
            newMessage.content = text;
            newMessage.createtime = [NSDate date];
            newMessage.flag = @(1);
            newMessage.msgType = @"text";
            newMessage.user = _currentFriend;
            Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:_currentFriend];
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
            [hud hide:YES afterDelay:1.0f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
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
    NSLog(@"Tapped avatar!");
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
