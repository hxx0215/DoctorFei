//
//  ShareUtil.m
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/22/15.
//
//

#import "ShareUtil.h"

@implementation ShareUtil
+ (instancetype)sharedShareUtil {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}
- (void)shareTo:(ShareType)type content:(NSDictionary *)content complete:(void (^)(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end))complete{
    switch (type) {
        case ShareTypeSinaWeibo:
        {
            [self shareWeibo:content complete:complete];
        }
            break;
            
        default:
            break;
    }
}
- (void)shareWeibo:(NSDictionary *)content complete:(void(^)(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end))complete{
    id<ISSContent> publishConetent = [ShareSDK content:content[@"content"] defaultContent:@"" image:nil title:content[@"title"] url:nil description:nil mediaType:SSPublishContentMediaTypeText];
    id<ISSContainer> container = [ShareSDK container];
    [container setIPhoneContainerWithViewController:content[@"vc"]];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES allowCallback:NO authViewStyle:SSAuthViewStyleModal viewDelegate:nil authManagerViewDelegate:nil];
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:publishConetent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:complete];
}
- (void)shareSMS:(NSDictionary *)content complete:(void(^)(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end)) complete{
    
}
@end
