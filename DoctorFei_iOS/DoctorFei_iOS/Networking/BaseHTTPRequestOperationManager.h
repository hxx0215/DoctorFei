//
//  BaseHTTPRequestOperationManager.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

#import "AFHTTPRequestOperationManager.h"

@interface BaseHTTPRequestOperationManager : AFHTTPRequestOperationManager
+ (BaseHTTPRequestOperationManager *)sharedManager;
- (void)defaultGetWithMethod:(NSString *)method WithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)defaultPostWithMethod:(NSString *)method WithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)defaultPostWithMethod:(NSString *)method WithParameters:(id)parameters WithBodyParameters:(id)bodyParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//上传音频
+ (void)uploadAudio: (NSString *)ext dataStream:(NSData *)data success:(void (^)(NSURLResponse *operation, id responseObject))success failure:(void (^)(NSURLResponse *operation, NSError *error))failure;
- (void)defaultAuth;
@end
