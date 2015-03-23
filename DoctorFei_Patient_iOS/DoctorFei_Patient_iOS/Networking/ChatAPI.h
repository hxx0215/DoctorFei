//
//  ChatAPI.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import "BaseHTTPRequestOperationManager.h"

@interface ChatAPI : BaseHTTPRequestOperationManager
+ (void)getChatWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)sendMessageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)uploadAudio: (NSString *)ext dataStream:(NSData *)data success:(void (^)(NSURLResponse *operation, id responseObject))success failure:(void (^)(NSURLResponse *operation, NSError *error))failure;
+ (void)setTempGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)sendTempGroupMessageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)getTempGroupChatLogWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
