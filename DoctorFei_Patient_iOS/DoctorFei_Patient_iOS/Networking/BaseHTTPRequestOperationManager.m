//
//  BaseHTTPRequestOperationManager.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//
#define kErrorDomain @"com.doctor.fei"
#import "BaseHTTPRequestOperationManager.h"
#import <JSONKit.h>
#import "NSString+Crypt.h"

@implementation BaseHTTPRequestOperationManager
+ (BaseHTTPRequestOperationManager *)sharedManager
{
    static BaseHTTPRequestOperationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self manager]initWithBaseURL:nil];
        _sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_sharedManager.responseSerializer setStringEncoding:NSUTF8StringEncoding];
        [_sharedManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain",@"text/html", nil]];
    });
    return _sharedManager;
}
- (void)defaultGetWithMethod:(NSString *)method WithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"%@",[parameters JSONString]);
    NSString *urlString = [NSString createResponseURLWithMethod:method Params:[parameters JSONString]];
    [[BaseHTTPRequestOperationManager sharedManager]GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *retStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
        NSDictionary *result = [retJson objectFromJSONString];
        NSLog(@"%@",result);
        if ([result[@"verification"]boolValue] && [result[@"error"]isEqual:[NSNull null]]) {
            NSArray *dataArray = result[@"data"];
            success(operation, dataArray);
        }
        else{
            NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : result[@"error"]}];
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

- (void)defaultPostWithMethod:(NSString *)method WithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    //    NSLog(@"%@",[parameters JSONString]);
    NSDictionary *param = @{@"picturename": parameters[@"picturename"]};
    NSString *urlString = [NSString createResponseURLWithMethod:method Params:[param JSONString]];

//    NSString *urlString = [NSString createResponseURLWithMethod:method Params:[parameters JSONString]];
    [[BaseHTTPRequestOperationManager sharedManager]POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[parameters[@"img"] dataUsingEncoding:NSUTF8StringEncoding] name:@"img"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *retStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
        NSDictionary *result = [retJson objectFromJSONString];
//                NSLog(@"%@",result);
        if ([result[@"verification"]boolValue] && [result[@"error"]isEqual:[NSNull null]]) {
            NSArray *dataArray = result[@"data"];
            success(operation, dataArray);
        }
        else{
            NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : result ? result[@"error"]: @"未知错误"}];
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
//    
//    [[BaseHTTPRequestOperationManager sharedManager]POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *retStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
//        NSDictionary *result = [retJson objectFromJSONString];
//        //        NSLog(@"%@",result);
//        if ([result[@"verification"]boolValue] && [result[@"error"]isEqual:[NSNull null]]) {
//            NSArray *dataArray = result[@"data"];
//            success(operation, dataArray);
//        }
//        else{
//            NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : result[@"error"]}];
//            failure(operation, error);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        failure(operation, error);
//    }];
}
- (void)defaultAuth{
    [[BaseHTTPRequestOperationManager sharedManager] GET:@"https://coding.net/u/feiyisheng/p/DoctorFYSAuth/git/raw/master/AuthFile" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSString *status = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([status isEqualToString:@"crash!"])
            exit(42);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
    }];
//    NSURL *url = [NSURL URLWithString:@"https://coding.net/u/feiyisheng/p/DoctorFYSAuth/git/raw/master/AuthFile"];
//    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,NSData *data, NSError *connectionError){
//        NSString *status = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if ([status isEqualToString:@"crash!"])
//            exit(42);
//    }];
}

- (void)defaultPostWithMethod:(NSString *)method WithParameters:(id)parameters WithBodyParameters:(id)bodyParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    //    NSLog(@"%@",[parameters JSONString]);
    NSString *urlString = [NSString createResponseURLWithMethod:method Params:[parameters JSONString]];
    [[BaseHTTPRequestOperationManager sharedManager] POST:urlString parameters:bodyParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *retStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
        NSDictionary *result = [retJson objectFromJSONString];
        NSLog(@"%@",result);
        
        if ([result[@"verification"]boolValue] && [result[@"error"]isEqual:[NSNull null]]) {
            NSArray *dataArray = result[@"data"];
            success(operation, dataArray);
        }
        else{
            NSError *error;
            if(result[@"error"])
            {
                error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : result[@"error"]}];
            }
            else
            {
                error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"其他错误"}];
            }
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

@end
