//
//  MobileAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "MobileAPI.h"
#define kMethodSetPushUser @"set.mobile.pushuser"
@implementation MobileAPI
+ (void)setPushUserWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodSetPushUser WithParameters:parameters success:success failure:failure];
}


@end
