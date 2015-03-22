//
//  AppDelegate.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "APService.h"
#import <CoreData+MagicalRecord.h>
#import "DeviceUtil.h"
#import "SetOnlineStateUtil.h"
#import "MobileAPI.h"
#import "SocketConnection.h"
#import "DataUtil.h"
#import <MobClick.h>
#import "ImageDetailViewController.h"

//shareSDK
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboApi.h"
#import "WeiboSDK.h"
//#ifndef DEBUG
//#define shareSDKKey @"63d7ba6195cf"
//#define shareSDKAPPSecret @"8c8732d0d3ea54b1e6dfa3fd443e91f4"
//#else
//#define shareSDKKey @
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //    [[NSUserDefaults standardUserDefaults] setObject:@(91) forKey:@"UserId"];
    // Override point for customization after application launch.
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif
    
    /*
     UMeng..需注册新Key
     
    [MobClick startWithAppkey:@"54928fcbfd98c58aaa00136c" reportPolicy:BATCH channelId:@""];
    
     */
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"DoctorFei.sqlite"];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    /*
     JPush相关
    
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    
     */
     
    [SetOnlineStateUtil online];
    [self setPushUser];
    [[SocketConnection sharedConnection]beginListen];
    [[SocketConnection sharedConnection]sendKeepAlive];
    [self initShareSDK];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [SetOnlineStateUtil offline];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [SetOnlineStateUtil offline];
    [[SocketConnection sharedConnection]stopListen];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [SetOnlineStateUtil online];
    [self setPushUser];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    if (userId) {
        [[SocketConnection sharedConnection]beginListen];
        [[SocketConnection sharedConnection]sendKeepAlive];
        [[SocketConnection sharedConnection]sendCheckMessages];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [APService registerDeviceToken:deviceToken];
    //使用UUID设置别名
//    [APService setAlias: [DeviceUtil getUUID] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    [APService handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
}


//- (void)tagsAliasCallback:(int)iResCode tags:(NSSet *)tags alias:(NSString *)alias {
//    NSString *callbackString = [NSString stringWithFormat:@"%d, alias: %@\n", iResCode, alias];
//    NSLog(@"TagsAlias回调:%@", callbackString);
//    if (iResCode != 0){
//        NSLog(@"注册别名失败");
//    }
//}
//
- (void)setPushUser {
    NSDictionary *params = @{
                             @"sn": [DeviceUtil getUUID],
                             @"cityid": @(0),
                             @"model": [DeviceUtil getDeviceModalDescription],
                             @"type": @(2)
                             };
    [MobileAPI setPushUserWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        if ([dataDict[@"state"]intValue] == 1) {
            NSLog(@"SetPushUserSuccess");
        }
        else{
            NSLog(@"SetPushUserFailedMessage:%@", dataDict[@"msg"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([self.window.rootViewController.presentedViewController isKindOfClass: [ImageDetailViewController class]])
    {
        ImageDetailViewController *secondController = (ImageDetailViewController *) self.window.rootViewController.presentedViewController;
        
        if (secondController.isPresented)
            return UIInterfaceOrientationMaskAll;
        else return UIInterfaceOrientationMaskPortrait;
    }
    else return UIInterfaceOrientationMaskPortrait;
}

- (void)initShareSDK{//使用mob.com的sharesdk账号为feiyisheng@126.com 密码为shengyifei
//    [ShareSDK registerApp:shareSDKKey];
    [ShareSDK registerApp:@"5577ff992136"];
    [self initializePlat];
}

- (void)initializePlat
{
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                             redirectUri:@"http://www.sharesdk.cn"];
    
    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                             redirectUri:@"http://www.sharesdk.cn"
                             weiboSDKCls:[WeiboSDK class]];
    
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                redirectUri:@"http://www.sharesdk.cn"
                                   wbApiCls:[WeiboApi class]];
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    /**
     连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
    [ShareSDK connectQZoneWithAppKey:@"100371282"
                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    //    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885" wechatCls:[WXApi class]];
    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885"
                           appSecret:@"64020361b8ec4c99936c0e3999a9f249"
                           wechatCls:[WXApi class]];
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
    
    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
}
@end
