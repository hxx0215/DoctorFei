//
//  UserAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/6.
//
//

#import "UserAPI.h"
#define kMethodUserInfomation @"get.user.infomation"
#define kMethodFeedBack @"set.feed.back"
#define kMethodSearchUser @"get.search.user"
@implementation UserAPI

+ (void)getUserInfomationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodUserInfomation WithParameters:parameters success:success failure:failure];
}

+ (void)setFeedBackWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodFeedBack WithParameters:parameters success:success failure:failure];
}
+ (void)searchUserWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSearchUser WithParameters:parameters success:success failure:failure];
}
@end
