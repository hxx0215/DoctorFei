//
//  ChatAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import "ChatAPI.h"
#define kMethodGetChat @"get.user.chatlog"
#define kMethodSendMessage @"set.doctorchat.send"
#define kMethodUploadAudio @"set.audio.add"
#define kMethodSetTempGroup @"set.chat.tempgroup"
#define kMethodSendTempGroupMessage @"set.chat.tempnote"
#define kMethodGetTempGroupChatLog @"get.chat.tempnote"
#define kMethodGetChatGroup @"get.chat.group"
#define kMethodSetChatGroup @"set.chat.group"
#define kMethodUpdateChatGroup @"update.chat.group"
#define kMethodDelChatGroup @"set.chat.groupdel"
#define kMethodGetChatGroupUser @"get.chat.user"
#define kMethodSetChatGroupUser @"set.chat.groupuser"
#define kMethodDelChatGroupUser @"set.chat.userdel"
#define kMethodGetChatNote @"get.chat.note"
#define kMethodSetChatNote @"set.chat.note"
#define kMethodGetChatGroupSend @"get.chat.groupsend"
#define kMethodSetChatGroupSend @"set.chat.groupsend"
#define kMethodSearchGroup @"get.search.group"
@implementation ChatAPI
+ (void)getChatWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetChat WithParameters:parameters success:success failure:failure];
}

+ (void)sendMessageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSendMessage WithParameters:parameters success:success failure:failure];
}

+ (void)uploadAudioWithParameters: (id)parameters WithBodyParameters:(id)bodyParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultPostWithMethod:kMethodUploadAudio WithParameters:parameters WithBodyParameters:bodyParameters success:success failure:failure];
}
+ (void)setTempGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSetTempGroup WithParameters:parameters success:success failure:failure];
}
+ (void)sendTempGroupMessageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSendTempGroupMessage WithParameters:parameters success:success failure:failure];
}
+ (void)getTempGroupChatLogWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetTempGroupChatLog WithParameters:parameters success:success failure:failure];
}
+ (void)getChatGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetChatGroup WithParameters:parameters success:success failure:failure];
}
+ (void)setChatGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodSetChatGroup WithParameters:parameters success:success failure:failure];
}
+ (void)updateChatGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodUpdateChatGroup WithParameters:parameters success:success failure:failure];
}
+ (void)delChatGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodDelChatGroup WithParameters:parameters success:success failure:failure];
}
+ (void)getChatUserWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodGetChatGroupUser WithParameters:parameters success:success failure:failure];
}
+ (void)setChatUserWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodSetChatGroupUser WithParameters:parameters success:success failure:failure];
}
+ (void)delChatUserWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodDelChatGroupUser WithParameters:parameters success:success failure:failure];
}
+ (void)getChatNoteWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodGetChatNote WithParameters:parameters success:success failure:failure];
}
+ (void)setChatNoteWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager]defaultGetWithMethod:kMethodSetChatNote WithParameters:parameters success:success failure:failure];
}

+ (void)getChatGroupSendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetChatGroupSend WithParameters:parameters success:success failure:failure];
}
+ (void)setChatGroupSendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSetChatGroupSend WithParameters:parameters success:success failure:failure];
}

+ (void)searchGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSearchGroup WithParameters:parameters success:success failure:failure];
}
@end
