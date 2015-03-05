//
//  DoctorAPI.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/1.
//
//

#import "DoctorAPI.h"
#define kMethodUpdateInfomation @"update.doctor.information"
#define kMethodLogin @"set.doctor.login"
#define kMethodOnline @"set.doctor.online"
#define kMethodQRCode @"set.doctor.qrscene"
#define kMethodFriend @"get.doctor.friend"
#define kMethodUserNote @"set.doctor.usernote"
#define kMethodUploadImage @"set.picture.add"
#define kMethodUserDescribe @"set.doctor.userdesribe"
#define kMethodSearchFriend @"get.search.user"
#define kMethodGetFriendInvitation @"get.friend.invitation"
#define kMethodSetFriendInvitation @"set.friend.invitation"
#define kMethodAddFriend @"set.doctor.friend"
#define kMethodDelFriend @"set.doctor.delfriend"
#define kMethodSetAudit @"set.doctor.audit"
#define kMethodGetAudit @"get.doctor.audit"
#define kMethodGetDoctorDaylog @"get.doctor.daylog"
#define kMethodSetDoctorDaylog @"set.doctor.daylog"
#define kMethodUpdateDoctorDaylog @"update.doctor.daylog"
#define kMethodDoctorShuoshuo @"get.doctor.shuoshuo"
#define kMethodDelDoctorShuoshuoOrDay @"set.doctor.delday"
#define kMethodSetDoctorShuoshuo @"set.doctor.shuoshuo"
#define kMethodUpdateDoctorShuoshuo @"update.doctor.shuoshuo"
#define kMethodGetDoctorSchedule @"get.doctor.schedule"
#define kMethodUpdateDoctorSchedule @"update.doctor.schedule"
#define kMethodGetDoctorDayarrange @"get.doctor.dayarrange"
#define kMethodSetDoctorDayarrange @"set.doctor.dayarrange"
#define kMethodGetDoctorFastreply @"get.doctor.fastreply"
#define kMethodSetDoctorFastreply @"set.doctor.fastreply"

#define kMethodGetFriendGroup @"get.doctor.friendgroup"
#define kMethodSetFriendGroup @"set.doctor.friendgroup"
#define kMethodUpdateFriendGroup @"update.doctor.friendgroup"
#define kMethodDelFriendGroup @"update.doctor.delfriendgroup"
#define kMethodMoveFriendGroup @"set.doctor.movefriend"

#define kMethodGetMemberHistory @"get.member.history"

#define kMethodGetMemberAppointment @"get.member.appointment"
#define kMethodSetMemberAppointmentAudit @"set.member.appointmentaudit"

#define kMethodSetDoctorReferral @"set.doctor.referral"
#define kMethodUpdateDoctorReferral @"update.doctor.referral"//终止转诊
#define kMethodGetDoctorReferral @"get.doctor.referral"
#define kMethodSetDoctorReferralAudit @"set.doctor.referralaudit"

@implementation DoctorAPI
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

+ (void)uploadImage: (UIImage *)image success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *str = [UIImageJPEGRepresentation(image, 0.8) base64EncodedStringWithOptions:0];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"|JH|"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"|KG|"];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"|HC|"];
    
    NSDictionary *params = @{
                             @"picturename": [NSString stringWithFormat:@"%d.jpg", (int)[[NSDate date] timeIntervalSince1970]],
                             @"img": str
                             };
    [DoctorAPI uploadImageWithParameters:params success:success failure:failure];
}

+ (void)uploadImageWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodUploadImage WithParameters:parameters success:success failure:failure];
}

+ (void)setUserDescribeWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUserDescribe WithParameters:parameters success:success failure:failure];
}

//添加好友，按检索条件查询
+ (void)searchFriendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodSearchFriend WithParameters:parameters success:success failure:failure];
}

//医生患者通用新的好友请求
+ (void)getFriendInvitationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodGetFriendInvitation WithParameters:parameters success:success failure:failure];
}
//医生患者通用同意或拒绝好友请求
+ (void)setFriendInvitationWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodSetFriendInvitation WithParameters:parameters success:success failure:failure];
}

+ (void)addFriendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodAddFriend WithParameters:parameters success:success failure:failure];
}

+ (void)delFriendWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodDelFriend WithParameters:parameters success:success failure:failure];
}

+ (void)getAuditWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodGetAudit WithParameters:parameters success:success failure:failure];
}

+ (void)setAuditWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodSetAudit WithParameters:parameters success:success failure:failure];
}

+ (void)DoctorShuoshuoWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodDoctorShuoshuo WithParameters:parameters success:success failure:failure];
}

+ (void)delDoctorShuoshuoOrDaylogWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodDelDoctorShuoshuoOrDay WithParameters:parameters success:success failure:failure];
}

+ (void)setDoctorDaylogWithParameters: (id)parameters WithBodyParameters:(id)bodyParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodSetDoctorDaylog WithParameters:parameters WithBodyParameters:bodyParameters success:success failure:failure];
}

+ (void)getDoctorDaylogWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodGetDoctorDaylog WithParameters:parameters success:success failure:failure];
}

+ (void)updateDoctorDaylogWithParameters: (id)parameters WithBodyParameters:(id)bodyParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodUpdateDoctorDaylog WithParameters:parameters WithBodyParameters:bodyParameters success:success failure:failure];
}

+ (void)setDoctorShuoshuoWithParameters: (id)parameters WithBodyParameters:(id)bodyParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodSetDoctorShuoshuo WithParameters:parameters WithBodyParameters:bodyParameters success:success failure:failure];
}

+ (void)updateDoctorShuoshuoWithParameters: (id)parameters WithBodyParameters:(id)bodyParameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultPostWithMethod:kMethodUpdateDoctorShuoshuo WithParameters:parameters WithBodyParameters:bodyParameters success:success failure:failure];
}

+ (void)getDoctorScheduleWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodGetDoctorSchedule WithParameters:parameters success:success failure:failure];
}

+ (void)updateDoctorScheduleWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodUpdateDoctorSchedule WithParameters:parameters success:success failure:failure];
}

+ (void)getDoctorDayarrangeWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodGetDoctorDayarrange WithParameters:parameters success:success failure:failure];
}

+ (void)setDoctorDayarrangeWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodSetDoctorDayarrange WithParameters:parameters success:success failure:failure];
}

+ (void)getDoctorFastreplyWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodGetDoctorFastreply WithParameters:parameters success:success failure:failure];
}

+ (void)setDoctorFastreplyWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodSetDoctorFastreply WithParameters:parameters success:success failure:failure];
}

//获取好友分组
+ (void)getDoctorFriendGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodGetFriendGroup WithParameters:parameters success:success failure:failure];
}
//添加好友分组
+ (void)setDoctorFriendGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodSetFriendGroup WithParameters:parameters success:success failure:failure];
}
//修改好友分组
+ (void)updateDoctorFriendGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodUpdateFriendGroup WithParameters:parameters success:success failure:failure];
}
//删除好友分组
+ (void)delDoctorFriendGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodDelFriendGroup WithParameters:parameters success:success failure:failure];
}
//移动好友到分组
+ (void)moveDoctorFriendGroupWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [[self sharedManager]defaultGetWithMethod:kMethodMoveFriendGroup WithParameters:parameters success:success failure:failure];
}

//获取患者病历本
+ (void)getMemberHistoryWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [[self sharedManager]defaultGetWithMethod:kMethodGetMemberHistory WithParameters:parameters success:success failure:failure];
}

//获取患者预约信息
+ (void)getAppointmentWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetMemberAppointment WithParameters:parameters success:success failure:failure];
}

//处理预约信息
+ (void)setAppointmentWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodSetMemberAppointmentAudit WithParameters:parameters success:success failure:failure];
}

//发起转诊
+ (void)initiateReferralWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodSetDoctorReferral WithParameters:parameters success:success failure:failure];
}

//终止转诊
+ (void)terminalReferralWithParameters:(id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodUpdateDoctorReferral WithParameters:parameters success:success failure:failure];
}

//获取转诊信息
+ (void)getReferralInfoWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodGetDoctorReferral WithParameters:parameters success:success failure:failure];
}

//处理转诊信息
+ (void)AuditReferralWithParameters: (id)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [[self sharedManager] defaultGetWithMethod:kMethodSetDoctorReferralAudit WithParameters:parameters success:success failure:failure];
}
@end
