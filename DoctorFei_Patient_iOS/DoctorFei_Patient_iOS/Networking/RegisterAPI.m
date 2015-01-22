//
//  RegisterAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

#import "RegisterAPI.h"
#define kMethodSendCode @"set.sms.sendcode"
#define kMethodRegister @"set.member.register"
#define kMethodForgotPassword @"update.member.repwd"

@implementation RegisterAPI

+ (void)getCpathaWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager] defaultGetWithMethod:kMethodSendCode WithParameters:parameters success:success failure:failure];
}

+ (void)registerWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager] defaultGetWithMethod:kMethodRegister WithParameters:parameters success:success failure:failure];
}
+ (void)forgotPasswordWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager] defaultGetWithMethod:kMethodForgotPassword WithParameters:parameters success:success failure:failure];
}

@end
