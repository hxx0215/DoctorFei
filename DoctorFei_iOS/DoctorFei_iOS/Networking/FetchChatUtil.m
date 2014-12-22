//
//  FetchChatUtil.m
//  ;
//
//  Created by GuJunjia on 14/12/5.
//
//

#import "FetchChatUtil.h"
#import "ChatAPI.h"
#import "Message.h"
#import "Chat.h"
#import "Friends.h"
#import "UserAPI.h"
//#import "DataUtil.h"
@implementation FetchChatUtil

+ (void)fetchChatWithParmas: (NSDictionary *)params {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSNumber *userId = @([params[@"userId"] intValue]);
    Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:userId];
    if (friend == nil) {
        NSDictionary *friendParam = @{
                                      @"doctorid": doctorId,
                                      @"userid": userId
                                      };
        [UserAPI getUserInfomationWithParameters:friendParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"%@",responseObject);
            NSDictionary *dataDict = [responseObject firstObject];
            if ([dataDict[@"state"]intValue] == 1) {
                Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:userId];
                if (friend == nil) {
                    friend = [Friends MR_createEntity];
                    friend.userId = userId;
                }
                friend.icon = dataDict[@"icon"];
                friend.realname = dataDict[@"realname"];
                friend.gender = @([dataDict[@"Gender"]intValue]);
                friend.mobile = dataDict[@"mobile"];
                friend.noteName = dataDict[@"notename"];
                friend.situation = dataDict[@"describe"];
            }
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            [self fetchHasUserIdChatWithParam:params];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
    else{
        [self fetchHasUserIdChatWithParam:params];
    }
}

+ (void)fetchHasUserIdChatWithParam: (NSDictionary *)params {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSNumber *userId = @([params[@"userId"] intValue]);
    if (doctorId == nil || userId == nil) {
        return;
    }
    NSDictionary *dict = @{
                           @"doctorid": doctorId,
                           @"userid": userId,
                           @"lastmsgid": params[@"minmsgid"]
                           };
    [ChatAPI getChatWithParameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetChat: %@", responseObject);
        NSArray *messageArray = (NSArray *)responseObject;
        Friends *messageFriend = [Friends MR_findFirstByAttribute:@"userId" withValue:userId];
        for (NSDictionary *dict in messageArray) {
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
            message.user = messageFriend;
        }
//        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:messageFriend];
        if (chat == nil) {
            chat = [Chat MR_createEntity];
            chat.user = messageFriend;
            chat.unreadMessageCount = @([params[@"total"]intValue]);
        }
        else{
            chat.unreadMessageCount = @([params[@"total"]intValue] + chat.unreadMessageCount.intValue);
        }
//        chat.unreadMessageCount = @([params[@"total"]intValue]);
        Message *message = [[Message MR_findByAttribute:@"user" withValue:messageFriend andOrderBy:@"messageId" ascending:YES]lastObject];
        chat.lastMessageTime = message.createtime;
        chat.lastMessageContent = message.content;
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        //发送通知通知刷新MainVC
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NewChatArrivedNotification" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];

}
@end
