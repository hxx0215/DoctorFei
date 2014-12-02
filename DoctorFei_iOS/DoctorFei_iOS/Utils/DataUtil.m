//
//  DataUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/2.
//
//

#import "DataUtil.h"

@implementation DataUtil

+ (void)cleanUserDefault
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserIcon"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserRealName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserHospital"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserDepartment"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserJobTitle"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserEmail"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserOtherContact"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
