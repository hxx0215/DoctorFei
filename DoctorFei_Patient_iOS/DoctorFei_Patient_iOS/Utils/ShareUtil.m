//
//  ShareUtil.m
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/22/15.
//
//

#import "ShareUtil.h"
#import "AGViewDelegate.h"

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
        case ShareTypeWeixiSession:
        {
            [self shareWeixin:content Type:type complete:complete];
        }
        case ShareTypeWeixiTimeline:
        {
            [self shareWeixin:content Type:type complete:complete];
        }
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
                          container:nil
                            content:publishConetent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:[AGViewDelegate sharedAGViewDelegate]
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:complete];
}
- (void)shareSMS:(NSDictionary *)content complete:(void(^)(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end)) complete{
    
}
- (void)shareWeixin:(NSDictionary *)content Type:(ShareType)type complete:(void(^)(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end))complete{
    id<ISSContent> publishContent = [ShareSDK content:content[@"content"]
                                       defaultContent:nil
                                                image:nil
                                                title:nil
                                                  url:nil
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStylePopup viewDelegate:nil
                                               authManagerViewDelegate:[AGViewDelegate sharedAGViewDelegate]];
    [ShareSDK shareContent:publishContent
                      type:type
               authOptions:authOptions
             statusBarTips:YES
                    result:complete];
}
@end
