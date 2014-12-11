//
//  MobileAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "MobileAPI.h"
#define kMethodSetPushUser @"set.mobile.pushuser"
#define kMethodGetVersion @"get.mobile.version"

@implementation MobileAPI
+ (void)setPushUserWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodSetPushUser WithParameters:parameters success:success failure:failure];
}

+ (void)getMobileVersionWithParameters:(id)parameters
                              succsess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetVersion
                                 WithParameters:parameters
                                        success:success
                                        failure:failure];
}
@end
