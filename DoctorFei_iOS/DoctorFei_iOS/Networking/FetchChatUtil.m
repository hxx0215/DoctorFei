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
#import "GroupChat.h"
@implementation FetchChatUtil

+ (void)newFriendWithDict:(NSDictionary *)dataDict userType: (NSNumber *)userType userId:(NSNumber *)userId{
    Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", userId, userType]];
    if (friend == nil) {
        friend = [Friends MR_createEntity];
        friend.userId = userId;
        friend.userType = userType;
    }
    friend.icon = dataDict[@"icon"];
    friend.realname = dataDict[@"RealName"];
    friend.gender = @([dataDict[@"Gender"]intValue]);
    friend.mobile = dataDict[@"Mobile"];
    friend.noteName = dataDict[@"notename"];
    friend.situation = dataDict[@"describe"];
    friend.email = dataDict[@"Email"];
    friend.hospital = dataDict[@"hospital"];
    friend.department = dataDict[@"department"];
    friend.jobTitle = dataDict[@"jobTitle"];
    friend.otherContact = dataDict[@"OtherContact"];
    friend.isFriend = @([dataDict[@"friend"] intValue]);
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
}

+ (void)fetchGeneralChatWithParmas: (NSDictionary *)params {
    int type = [params[@"type"]intValue];
    if (type < 3) {
        [self fetchChatWithParmas:params];
    }else if(type == 4){
        [self fetchTempGroupChatWithParmas: params];
    }else if (type == 3) {
        [self fetchGroupChatWithParmas: params];
    }
}
+ (void)fetchGroupHasGroupInfoWithParams: (NSDictionary *)params {
    NSNumber *groupId = @([params[@"groupid"]intValue]);
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSNumber *lastmsgid = @0;
    Chat *currentChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ && chatId == %@", @3, groupId]];
    if (currentChat != nil) {
        Message *lastMessage = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"chat == %@", currentChat] sortedBy:@"messageId" ascending:NO];
        if (lastMessage != nil) {
            lastmsgid = lastMessage.messageId;
        }
    }
    NSDictionary *requestDict = @{
                                  @"userid": userId,
                                  @"usertype": @2,
                                  @"groupid": groupId,
                                  @"lastmsgid": lastmsgid
                                  };
    [ChatAPI getChatNoteWithParameters:requestDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get Group Chat: %@", responseObject);
        Chat *currentChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ && chatId == %@", @3, groupId]];
        if (currentChat == nil) {
            currentChat = [Chat MR_createEntity];
            currentChat.chatId = groupId;
            currentChat.type = @3;
        }
        currentChat.title = params[@"title"];
        GroupChat *groupChat = [GroupChat MR_findFirstByAttribute:@"groupId" withValue:groupId];
        if (groupChat == nil) {
            groupChat = [GroupChat MR_createEntity];
            groupChat.groupId = groupId;
        }
        groupChat.name = params[@"title"];
        currentChat.groupChat = groupChat;
        NSArray *messageArray = (NSArray *)responseObject;
        NSMutableSet *lostInfomationUsers = [NSMutableSet set];
        for (NSDictionary *dict in messageArray) {
            Friends *messageFriend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", @([dict[@"userid"] intValue]), @([dict[@"usertype"] intValue])]];
            if (messageFriend == nil && [dict[@"userid"]intValue] != userId.intValue) {
                messageFriend = [Friends MR_createEntity];
                messageFriend.userId = @([dict[@"userid"]intValue]);
                messageFriend.userType = @([dict[@"usertype"] intValue]);
                [lostInfomationUsers addObject:messageFriend];
            }
            if (messageFriend) {
                [currentChat addUserObject:messageFriend];
            }
            Message *message = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat: @"messageId == %@ && chat == %@", dict[@"id"], currentChat]];
            if (message == nil) {
                message = [Message MR_createEntity];
                message.messageId = dict[@"id"];
            }
            message.msgType = dict[@"msgtype"];
            message.createtime = [NSDate dateWithTimeIntervalSince1970:[dict[@"ctime"]intValue]];
            message.content = dict[@"content"];
            message.user = messageFriend;
            message.chat = currentChat;
        }
        currentChat.unreadMessageCount = @([currentChat.unreadMessageCount intValue] + [params[@"total"]intValue]);
        [self fetchLostInfomationWithSet: lostInfomationUsers];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        //发送通知通知刷新MainVC
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NewChatArrivedNotification" object:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];

}
+ (void)fetchGroupChatWithParmas: (NSDictionary *)params {
    NSNumber *groupId = @([params[@"groupid"]intValue]);
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    GroupChat *groupChat = [GroupChat MR_findFirstByAttribute:@"groupId" withValue:groupId];
    if (groupChat == nil) {
        NSDictionary *param = @{
                                @"groupid": groupId,
                                @"userid": userId,
                                @"userType": @2
                                };
        [ChatAPI getGroupInfoWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
            NSDictionary *dict = [responseObject firstObject];
            if (dict != nil) {
                GroupChat *groupChat = [GroupChat MR_findFirstByAttribute:@"groupId" withValue:@([dict[@"groupid"] intValue])];
                if (groupChat == nil) {
                    groupChat = [GroupChat MR_createEntity];
                    groupChat.groupId = @([dict[@"groupid"] intValue]);
                }
                groupChat.name = dict[@"name"];
                groupChat.flag = @([dict[@"flag"] intValue]);
                groupChat.address = [dict[@"address"] isKindOfClass:[NSString class]] ? dict[@"address"] : nil;
                groupChat.taxis = @([dict[@"taxis"] intValue]);
                groupChat.latitude = @([dict[@"lat"]doubleValue]);
                groupChat.longtitude = @([dict[@"long"]doubleValue]);
                groupChat.visible = @([dict[@"visible"] intValue]);
                groupChat.icon = dict[@"icon"];
                groupChat.note = [dict[@"note"] isKindOfClass:[NSString class]] ? dict[@"note"]: nil;
                groupChat.total = @([dict[@"total"]intValue]);
                groupChat.allowDisturb = @([dict[@"allowdisturb"] intValue]);
                [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
                [self fetchGroupHasGroupInfoWithParams:params];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }else{
        [self fetchGroupHasGroupInfoWithParams:params];
    }
}
+ (void)fetchChatWithParmas: (NSDictionary *)params {
    NSNumber *userId = @([params[@"userId"] intValue]);
    NSNumber *userType = @([params[@"usertype"] intValue]);
    Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", userId, userType]];
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
    }
    else{
        [self fetchHasUserIdChatWithParam:params];
    }
}

+ (void)fetchHasUserIdChatWithParam: (NSDictionary *)params {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSNumber *userId = @([params[@"userId"] intValue]);
    NSNumber *userType = @([params[@"usertype"]intValue]);
    NSNumber *chatType = @([params[@"type"]intValue]);
    if (doctorId == nil || userId == nil || userType == nil || chatType == nil) {
        return;
    }
    Friends *friend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", userId, userType]];
    Chat *chat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND (ANY user == %@)", chatType, friend]];
    if (chat == nil) {
        chat = [Chat MR_createEntity];
        chat.type = chatType;
        chat.user = [chat.user setByAddingObject:friend];
    }
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];

    Message *lastMessage = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"chat == %@", chat] sortedBy:@"messageId" ascending:NO];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:userId forKey:@"userid"];
    [dict setObject:userType forKey:@"usertype"];
    if (lastMessage) {
        [dict setObject:lastMessage.messageId forKey:@"lastmsgid"];
    }
    [dict setObject:doctorId forKey:@"doctorid"];
    [ChatAPI getChatWithParameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetChat: %@", responseObject);
        NSArray *messageArray = (NSArray *)responseObject;
        Friends *messageFriend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", userId, userType]];
        Chat *messageChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND (ANY user == %@)", chatType, friend]];
        for (NSDictionary *dict in messageArray) {
            Message *message = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat: @"messageId == %@ && chat == %@", dict[@"id"], messageChat]];
//                Message *message = [Message MR_findFirstByAttribute:@"messageId" withValue:dict[@"id"]];
            if (message == nil) {
                message = [Message MR_createEntity];
                message.messageId = dict[@"id"];
            }
            message.content = dict[@"content"];
            message.createtime = [NSDate dateWithTimeIntervalSince1970:[dict[@"createtime"]intValue]];
            message.msgType = dict[@"msgtype"];
            message.flag = @([dict[@"flag"]intValue]);
            if (chatType.intValue == 1) {
                if ([dict[@"Fromid"]intValue] == doctorId.intValue) {
                    message.user = nil;
                }else{
                    message.user = messageFriend;
                }
            }else{
                message.user = [dict[@"flag"] intValue] ? nil :messageFriend;
            }
            message.chat = messageChat;
        }
        messageChat.unreadMessageCount = @([messageChat.unreadMessageCount intValue] + [params[@"total"]intValue]);
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        //发送通知通知刷新MainVC
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NewChatArrivedNotification" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

+ (void)fetchLostInfomationWithSet: (NSSet *)userSet {
    dispatch_group_t group = dispatch_group_create();
    for (Friends *friend in userSet) {
        dispatch_group_enter(group);
        NSDictionary *friendParam = @{@"userid": friend.userId};
        if (friend.userType.intValue == 2) {
            [UserAPI getDoctorInfomationWithParameters:friendParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dataDict = [responseObject firstObject];
                if (dataDict.count > 0) {
                    [self newFriendWithDict:dataDict userType:friend.userType userId:friend.userId];
                }
                dispatch_group_leave(group);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error.localizedDescription);
            }];
        }else{
            [UserAPI getMemberInfomationWithParameters:friendParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dataDict = [responseObject firstObject];
                if (dataDict.count > 0) {
                    [self newFriendWithDict:dataDict userType:friend.userType userId:friend.userId];
                }
                dispatch_group_leave(group);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error.localizedDescription);
            }];
        }
    }
    dispatch_group_wait(group, 30);
}
+ (void)fetchTempGroupChatWithParmas: (NSDictionary *)params {
    NSNumber *groupId = @([params[@"groupid"]intValue]);
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
//    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    NSNumber *lastmsgid = @0;
    Chat *currentChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ && chatId == %@", @4, groupId]];
    if (currentChat != nil) {
        Message *lastMessage = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"chat == %@", currentChat] sortedBy:@"messageId" ascending:NO];
        if (lastMessage != nil) {
            lastmsgid = lastMessage.messageId;
        }
    }
    NSDictionary *requestDict = @{
                                  @"userid": userId,
                                  @"usertype": @2,
                                  @"groupid": groupId,
                                  @"lastmsgid": lastmsgid
                           };
    [ChatAPI getTempGroupChatLogWithParameters:requestDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get TempGroup Chat: %@", responseObject);
        Chat *currentChat = [Chat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ && chatId == %@", @4, groupId]];
        if (currentChat == nil) {
            currentChat = [Chat MR_createEntity];
            currentChat.chatId = groupId;
            currentChat.type = @4;
        }
        currentChat.title = params[@"title"];
        NSArray *messageArray = (NSArray *)responseObject;
        NSMutableSet *lostInfomationUsers = [NSMutableSet set];
        for (NSDictionary *dict in messageArray) {
            Friends *messageFriend = [Friends MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@ && userType == %@", @([dict[@"userid"] intValue]), @([dict[@"usertype"] intValue])]];
            if (messageFriend == nil && [dict[@"userid"]intValue] != userId.intValue) {
                messageFriend = [Friends MR_createEntity];
                messageFriend.userId = @([dict[@"userid"]intValue]);
                messageFriend.userType = @([dict[@"usertype"] intValue]);
                [lostInfomationUsers addObject:messageFriend];
            }
            if (messageFriend) { 
                [currentChat addUserObject:messageFriend];
            }
            Message *message = [Message MR_findFirstWithPredicate:[NSPredicate predicateWithFormat: @"messageId == %@ && chat == %@", dict[@"id"], currentChat]];
            if (message == nil) {
                message = [Message MR_createEntity];
                message.messageId = dict[@"id"];
            }
            message.msgType = dict[@"msgtype"];
            message.createtime = [NSDate dateWithTimeIntervalSince1970:[dict[@"ctime"]intValue]];
            message.content = dict[@"content"];
            message.user = messageFriend;
            message.chat = currentChat;
        }
        currentChat.unreadMessageCount = @([currentChat.unreadMessageCount intValue] + [params[@"total"]intValue]);
        [self fetchLostInfomationWithSet: lostInfomationUsers];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        //发送通知通知刷新MainVC
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NewChatArrivedNotification" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];

}
@end
