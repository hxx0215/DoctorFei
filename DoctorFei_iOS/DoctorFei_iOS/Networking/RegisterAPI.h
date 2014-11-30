//
//  RegisterAPI.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

#import "BaseHTTPRequestOperationManager.h"

@interface RegisterAPI : BaseHTTPRequestOperationManager

+ (void)getCpathaWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)registerWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
