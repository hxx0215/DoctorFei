//
//  ShareUtil.h
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/22/15.
//
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

@interface ShareUtil : NSObject
+ (instancetype)sharedShareUtil;
- (void)shareTo:(ShareType)type content:(NSDictionary *)content complete:(void(^)(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end))complete;
@end
