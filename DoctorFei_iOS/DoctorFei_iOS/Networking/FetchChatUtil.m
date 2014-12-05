//
//  FetchChatUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import "FetchChatUtil.h"
#import "ChatAPI.h"
#import "Message.h"
#import "Chat.h"
@implementation FetchChatUtil

+ (void)fetchChatWithParmas: (NSDictionary *)params {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
//    NSNumber *userId = params[@"userId"];
    NSDictionary *dict = @{
                           @"doctorid": doctorId,
                           @"userid": params[@"userId"],
                           @"lastmsgid": params[@"minmsgid"]
                           };
    [ChatAPI getChatWithParameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetChat: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

@end
