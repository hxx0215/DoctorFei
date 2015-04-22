//
//  DataUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/2.
//
//

#import "DataUtil.h"
#import "Friends.h"
#import "Chat.h"
#import "Message.h"
#import "Groups.h"
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

+ (void)cleanCoreData {
    [Friends MR_truncateAll];
    [Chat MR_truncateAll];
    [Message MR_truncateAll];
    [Groups MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
}

+ (NSDate *)dateaFromFormatedString : (NSString *)formatedString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter dateFromString:formatedString];
}

+ (NSAttributedString *)nameStringForFriend : (Friends *)currentFriend {
    if (currentFriend.noteName && currentFriend.noteName.length > 0) {
        NSString *nameString = [NSString stringWithFormat:@"%@(%@)",currentFriend.noteName, currentFriend.realname];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:nameString];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xAAAAAA) range:NSMakeRange(currentFriend.noteName.length, currentFriend.realname.length + 2)];
        return attributedString;
    }
    else{
        return [[NSAttributedString alloc]initWithString:currentFriend.realname?currentFriend.realname:@"无姓名"];
    }
}

@end
