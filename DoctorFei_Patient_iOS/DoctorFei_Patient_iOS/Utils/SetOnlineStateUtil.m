//
//  SetOnlineStateUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "SetOnlineStateUtil.h"
#import "MemberAPI.h"
@implementation SetOnlineStateUtil

+ (void)online {
    [self setOnlineStateWithStatue:@(1)];
}

+ (void)offline {
    [self setOnlineStateWithStatue:@(2)];
}

+ (void)setOnlineStateWithStatue: (NSNumber *) statue {
    NSString *memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    if (memberId) {
        NSDictionary *params = @{
                                 @"memberid": memberId,
                                 @"online": statue
                                 };
        [MemberAPI onlineWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dataDict = [responseObject firstObject];
            if ([dataDict[@"state"]intValue] == 1) {
                NSLog(@"SetOnlineStateSuccess! State = %@", [statue stringValue]);
            }
            else {
                NSLog(@"SetOnlineStateFailed! State = %@", [statue stringValue]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
    else{
        NSLog(@"MemberId is nil");
    }
}
@end
