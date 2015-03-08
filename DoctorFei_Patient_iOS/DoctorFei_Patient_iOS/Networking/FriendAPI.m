//
//  FriendAPI.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/8.
//
//

#define kMethodGetInvitation @"get.friend.invitation"
#define kMethodSetInvitation @"set.friend.invitation"
#define kMethodGetCheck @"get.friend.check"

#import "FriendAPI.h"

@implementation FriendAPI
+ (void)getInvitationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager] defaultGetWithMethod:kMethodGetInvitation WithParameters:parameters success:success failure:failure];
}
+ (void)setInvitationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSetInvitation WithParameters:parameters success:success failure:failure];
}
+ (void)getCheckWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetCheck WithParameters:parameters success:success failure:failure];
}

@end
