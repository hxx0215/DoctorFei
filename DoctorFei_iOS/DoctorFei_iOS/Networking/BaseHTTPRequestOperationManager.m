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
        [_sharedManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    });
    return _sharedManager;
}
- (void)defaultGetWithMethod:(NSString *)method WithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
//    NSLog(@"%@",[parameters JSONString]);
    NSString *urlString = [NSString createResponseURLWithMethod:method Params:[parameters JSONString]];
    [[BaseHTTPRequestOperationManager sharedManager]GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *retStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
        NSDictionary *result = [retJson objectFromJSONString];
//        NSLog(@"%@",result);
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
            NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : result[@"error"]}];
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


//上传音频
+ (void)uploadAudio: (NSString *)ext dataStream:(NSData *)data success:(void (^)(NSURLResponse *operation, id responseObject))success failure:(void (^)(NSURLResponse *operation, NSError *error))failure
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:ext,@"ext",nil];
    NSString *jsonStr = [dic JSONString];
    NSURL *URL = [NSURL URLWithString:[NSString createResponseURLWithMethod:@"set.audio.add" Params:jsonStr]];
    
    //    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    NSString *TWITTERFON_FORM_BOUNDARY = @"AABBCC";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    
    ////添加分界线，换行---文件要先声明
    [body appendFormat:@"%@\r\n",MPboundary];
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"imgFile\"; filename=\"test.wav\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: audio/wav\r\n\r\n"];
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    //建立连接，设置代理
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        if (data)
        {
            NSString *retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
            NSLog(@"%@",retJson);
            NSDictionary* dic = [retJson objectFromJSONString];
            //    {"verification":true,"total":1,"data":[{"state":1,"msg":"http://113.105.159.115/Picture/201410/302117447717.png"}],"error":null}
            if ([[dic objectForKey:@"total"] integerValue]>=1)
            {
                NSArray* array = [dic objectForKey:@"data"];
//                NSDictionary *dicData = [array objectAtIndex:0];
//                imagePath = [dicData objectForKey:@"msg"];
                success(response,array);
            }
            else
            {
                failure(response,connectionError);
            }
        }
        else{
            failure(response,connectionError);
        }
        
    }];
}
@end
