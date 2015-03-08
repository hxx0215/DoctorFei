//
//  FriendAPI.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/8.
//
//

#import "BaseHTTPRequestOperationManager.h"

@interface FriendAPI : BaseHTTPRequestOperationManager
+ (void)getInvitationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)setInvitationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)getCheckWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
