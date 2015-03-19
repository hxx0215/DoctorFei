//
//  ChatAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import "ChatAPI.h"
#define kMethodGetChat @"get.user.chatlog"
#define kMethodSendMessage @"set.doctorchat.send"
#define kMethodUploadAudio @"set.audio.add"
#import "NSString+Crypt.h"
#import <JSONKit.h>
@implementation ChatAPI
+ (void)getChatWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetChat WithParameters:parameters success:success failure:failure];
}

+ (void)sendMessageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSendMessage WithParameters:parameters success:success failure:failure];
}
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
