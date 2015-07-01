//
//  SetOnlineStateUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import "SetOnlineStateUtil.h"
#import "DoctorAPI.h"
@implementation SetOnlineStateUtil

+ (void)online {
    [self setOnlineStateWithStatue:@(1)];
}

+ (void)offline {
    [self setOnlineStateWithStatue:@(0)];
}

+ (void)setOnlineStateWithStatue: (NSNumber *) statue {
    NSString *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    if (doctorId) {
        NSDictionary *params = @{
                                 @"doctorid": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],
                                 @"online": statue
                                 };
        [DoctorAPI onlineWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        NSLog(@"DoctorId is nil");
    }
}
@end
