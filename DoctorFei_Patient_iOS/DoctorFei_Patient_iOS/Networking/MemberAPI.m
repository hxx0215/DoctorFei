//
//  DoctorAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/1.
//
//

#import "MemberAPI.h"
#define kMethodUpdateInfomation @"update.member.information"
#define kMethodLogin @"set.member.login"
#define kMethodOnline @"set.member.online"
#define kMethodQRCode @"set.member.qrscene"
#define kMethodFriend @"get.member.friend"
#define kMethodUserNote @"set.member.usernote"
#define kMethodUploadImage @"set.picture.add"
#define kMethodUserDescribe @"set.member.userdesribe"
#define kMethodDelFriend @"set.member.delfriend"

@implementation MemberAPI
+ (void)updateInfomationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUpdateInfomation WithParameters:parameters success:success failure:failure];
}
+ (void)loginWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodLogin WithParameters:parameters success:success failure:failure];
}

+ (void)onlineWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodOnline WithParameters:parameters success:success failure:failure];
}
+ (void)getQRCodeWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodQRCode WithParameters:parameters success:success failure:failure];
}
+ (void)getFriendsWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodFriend WithParameters:parameters success:success failure:failure];
}

+ (void)setUserNoteWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUserNote WithParameters:parameters success:success failure:failure];
}

+ (void)uploadImageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodUploadImage WithParameters:parameters success:success failure:failure];
}

+ (void)setUserDescribeWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUserDescribe WithParameters:parameters success:success failure:failure];
}

+ (void)delFriendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodDelFriend WithParameters:parameters success:success failure:failure];
}

@end
