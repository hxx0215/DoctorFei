//
//  UploadImage.m
//  DoctorFei_iOS
//
//  Created by hxx on 12/12/14.
//
//

#import "UploadImage.h"
#import "NSString+Crypt.h"

@implementation UploadImage
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static UploadImage * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}
- (void)uploadImage:(UIImage *)image completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))complete{
//    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
//    hud.dimBackground = YES;
//    [hud setLabelText:@"图片上传中..."];
//    NSDictionary *params = @{
//                             @"picturename": [NSString stringWithFormat:@"%d.jpg", (int)[[NSDate date] timeIntervalSince1970]],
//                             @"img": [UIImageJPEGRepresentation(image, 0.5) base64EncodedStringWithOptions:0]
//                             };
    NSString *str = [UIImageJPEGRepresentation(image, 0.5) base64EncodedStringWithOptions:0];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"|JH|"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"|KG|"];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"|HC|"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *jsonStr = [NSString stringWithFormat:@"{\"picturename\":\"%@\"}",[NSString stringWithFormat:@"%d.jpg", (int)[[NSDate date] timeIntervalSince1970]]];
    request.URL = [NSURL URLWithString:[NSString createResponseURLWithMethod:@"set.picture.add" Params:jsonStr]];
    NSString *body = [NSString stringWithFormat:@"img=%@",str];
    NSData *jsonBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *contentType = @"application/x-www-form-urlencoded; charset=utf-8";
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonBody];
    NSString *postLength = [NSString stringWithFormat:@"%d",[jsonBody length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        NSString *retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
        NSLog(@"%@",retJson);
        complete(response,data,connectionError);
    }];
}
@end
