//
//  MobileAPI.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "BaseHTTPRequestOperationManager.h"

@interface MobileAPI : BaseHTTPRequestOperationManager
+ (void)setPushUserWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)getMobileVersionWithParameters: (id)parameters succsess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
