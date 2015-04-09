//
//  DoctorAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/1.
//
//

#import "MemberAPI.h"
#define kMethodUpdateInfomation @"update.member.information"
#define kMethodLogin @"set.member.login"
#define kMethodOnline @"set.member.online"
#define kMethodQRCode @"set.member.qrscene"
#define kMethodFriend @"get.member.friend"
#define kMethodUserNote @"set.member.usernote"
#define kMethodUploadImage @"set.picture.add"
#define kMethodUserDescribe @"set.member.userdesribe"
#define kMethodDelFriend @"set.member.delfriend"
#define kMethodGetInfomation @"get.member.information"
#define kMethodGetHistory @"get.member.history"
#define kMethodSetHistory @"set.member.history"
#define kMethodGetOpenInfo @"get.member.openinfo"
#define kMethodSetOpenInfo @"set.member.openinfo"
#define kMethodGetAppointment @"get.member.appointment"
#define kMethodSetAppointment @"set.member.appointment"
#define kMethodSendMessage @"set.member.send"
#define kMethodGetChatLog @"get.member.chatlog"
#define kMethodModifyPwd @"update.member.modifypwd"
#define kMethodSetFriend @"set.member.friend"
#define kMethodGetDoctorSchedule @"get.doctor.schedule"
#define kMethodGetDoctorShuoshuo @"get.doctor.shuoshuo"
#define kMethodGetAreaList @"get.area.list"
#define kMethodGetOrgInfo @"get.org.info"
#define kMethodGetProjectInformation @"get.project.information"
@implementation MemberAPI
+ (void)updateInfomationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUpdateInfomation WithParameters:parameters success:success failure:failure];
}
+ (void)loginWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodLogin WithParameters:parameters success:success failure:failure];
}

+ (void)onlineWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodOnline WithParameters:parameters success:success failure:failure];
}
+ (void)getQRCodeWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodQRCode WithParameters:parameters success:success failure:failure];
}
+ (void)getFriendsWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodFriend WithParameters:parameters success:success failure:failure];
}

+ (void)setUserNoteWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUserNote WithParameters:parameters success:success failure:failure];
}

+ (void)uploadImageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodUploadImage WithParameters:parameters success:success failure:failure];
}

+ (void)uploadImage:(UIImage *)image success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation * operation, NSError *error))failure{
    NSString *str = [UIImageJPEGRepresentation(image, 0.8) base64EncodedStringWithOptions:0];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"|JH|"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"|KG|"];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"|HC|"];
    
    NSDictionary *params = @{
                             @"picturename": [NSString stringWithFormat:@"%d.jpg", (int)[[NSDate date] timeIntervalSince1970]],
                             @"img": str
                             };
    [MemberAPI uploadImageWithParameters:params success:success failure:failure];
}
+ (void)setUserDescribeWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUserDescribe WithParameters:parameters success:success failure:failure];
}

+ (void)delFriendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodDelFriend WithParameters:parameters success:success failure:failure];
}

+ (void)getInfomationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetInfomation WithParameters:parameters success:success failure:failure];
}

+ (void)getHistoryWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetHistory WithParameters:parameters success:success failure:failure];
}

+ (void)setHistoryWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSetHistory WithParameters:parameters success:success failure:failure];
}

+ (void)getOpenInfoWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetOpenInfo WithParameters:parameters success:success failure:failure];
}

+ (void)setOpenInfoWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSetOpenInfo WithParameters:parameters success:success failure:failure];
}

+ (void)sendMessageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSendMessage WithParameters:parameters success:success failure:failure];
}
+ (void)getChatLogWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetChatLog WithParameters:parameters success:success failure:failure];
}
+ (void)modifyPwdWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodModifyPwd WithParameters:parameters success:success failure:failure];
}
+ (void)setFriendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSetFriend WithParameters:parameters success:success failure:failure];
}
//添加预约
+ (void)setAppointmentWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodSetAppointment WithParameters:parameters success:success failure:failure];
}
//获取医生日程
+ (void)getDoctorScheduleWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetDoctorSchedule WithParameters:parameters success:success failure:failure];
}
//获取医生说说
+ (void)getDoctorShuoShuoWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetDoctorShuoshuo WithParameters:parameters success:success failure:failure];
}
//获取地区列表
+ (void)getAreaListWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetAreaList WithParameters:parameters success:success failure:failure];
}
//获取机构列表
+ (void)getOrgListWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetOrgInfo WithParameters:parameters success:success failure:failure];
}
+ (void)getOutStandingSampleWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetProjectInformation WithParameters:parameters success:success failure:failure];
}
@end

