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

+ (void)newFriendWithDict:(NSDictionary *)dataDict userType: (NSNumber *)userType userId:(NSNumber *)userId{
    Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", userId, userType]];
    if (friend == nil) {
        friend = [Friends MR_createEntity];
        friend.userId = userId;
        friend.userType = @2;
    }
    friend.icon = dataDict[@"icon"];
    friend.realname = dataDict[@"realname"];
    friend.gender = @([dataDict[@"Gender"]intValue]);
    friend.mobile = dataDict[@"mobile"];
    friend.noteName = dataDict[@"notename"];
    friend.situation = dataDict[@"describe"];
    friend.email = dataDict[@"Email"];
    friend.hospital = dataDict[@"hospital"];
    friend.department = dataDict[@"department"];
    friend.otherContact = dataDict[@"OtherContact"];
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
}

+ (void)fetchChatWithParmas: (NSDictionary *)params {
//    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSNumber *userId = @([params[@"userId"] intValue]);
    NSNumber *userType = @([params[@"userType"] intValue]);
    Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", userId, userType]];
//    Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:userId];
    if (friend == nil) {
        NSDictionary *friendParam = @{@"userid": userId};
        if (userType.intValue == 2) {
            [UserAPI getDoctorInfomationWithParameters:friendParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dataDict = [responseObject firstObject];
                if (dataDict.count > 0) {
                    [self newFriendWithDict:dataDict userType:userType userId:userId];
                    [self fetchHasUserIdChatWithParam:params];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error.localizedDescription);
            }];
        }else{
            [UserAPI getMemberInfomationWithParameters:friendParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dataDict = [responseObject firstObject];
                if (dataDict.count > 0) {
                    [self newFriendWithDict:dataDict userType:userType userId:userId];
                    [self fetchHasUserIdChatWithParam:params];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error.localizedDescription);
            }];
        }
//        NSDictionary *friendParam = @{
//                                      @"doctorid": doctorId,
//                                      @"userid": userId
//                                      };
//        [UserAPI getUserInfomationWithParameters:friendParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
////            NSLog(@"%@",responseObject);
//            NSDictionary *dataDict = [responseObject firstObject];
//            if ([dataDict[@"state"]intValue] == 1) {
//                Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:userId];
//                if (friend == nil) {
//                    friend = [Friends MR_createEntity];
//                    friend.userId = userId;
//                }
//                friend.icon = dataDict[@"icon"];
//                friend.realname = dataDict[@"realname"];
//                friend.gender = @([dataDict[@"Gender"]intValue]);
//                friend.mobile = dataDict[@"mobile"];
//                friend.noteName = dataDict[@"notename"];
//                friend.situation = dataDict[@"describe"];
//            }
//            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
//            [self fetchHasUserIdChatWithParam:params];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"%@",error.localizedDescription);
//        }];
    }
    else{
        [self fetchHasUserIdChatWithParam:params];
    }
}

+ (void)fetchHasUserIdChatWithParam: (NSDictionary *)params {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSNumber *userId = @([params[@"userId"] intValue]);
    NSNumber *userType = @([params[@"userType"]intValue]);
    NSNumber *chatType = @([params[@"type"]intValue]);
    if (doctorId == nil || userId == nil || userType == nil || chatType == nil) {
        return;
    }
    Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@"]];
    Chat *chat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND (ANY user == %@)", chatType, friend]];
    if (chat == nil) {
        chat = [Chat MR_createEntity];
        chat.type = chatType;
        [chat.user setByAddingObject:friend];
    }
//    Friends *friend = [Friends MR_findFirstByAttribute:@"userId" withValue:userId];
    Message *lastMessage = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"chat == %@ AND user == %@", chat,friend] sortedBy:@"messageId" ascending:YES];
//    Message *lastMessage = [[Message MR_findByAttribute:@"user" withValue:friend andOrderBy:@"messageId" ascending:YES]lastObject];
    NSDictionary *dict;
    if (lastMessage) {
        dict = @{
                 @"doctorid": doctorId,
                 @"userid": userId,
                 @"usertype": userType,
                 @"lastmsgid": lastMessage.messageId
                 };
    }
    else{
        dict = @{@"doctorid": doctorId, @"userid": userId, @"userType": userType};
    }
    
    

    [ChatAPI getChatWithParameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetChat: %@", responseObject);
        NSArray *messageArray = (NSArray *)responseObject;
//        Friends *messageFriend = [Friends MR_findFirstByAttribute:@"userId" withValue:userId];
        Friends *messageFriend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@"]];
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
            message.user = [dict[@"flag"] intValue] ? nil :messageFriend;
        }
//        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
//        Chat *chat = [Chat MR_findFirstByAttribute:@"user" withValue:messageFriend];
//        if (chat == nil) {
//            chat = [Chat MR_createEntity];
//            chat.user = messageFriend;
//            chat.unreadMessageCount = @([params[@"total"]intValue]);
//        }
//        else{
//            chat.unreadMessageCount = @([params[@"total"]intValue] + chat.unreadMessageCount.intValue);
//        }
        chat.unreadMessageCount = @(chat.unreadMessageCount.intValue + [params[@"total"]intValue]);
        
//        Message *message = [[Message MR_findByAttribute:@"user" withValue:messageFriend andOrderBy:@"messageId" ascending:YES]lastObject];
//        Message *message = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"chat == %@ AND user == %@", chat,friend] sortedBy:@"messageId" ascending:YES];
//        chat.lastMessageTime = message.createtime;
//        chat.lastMessageContent = message.content;
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        //发送通知通知刷新MainVC
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NewChatArrivedNotification" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];

}
@end
