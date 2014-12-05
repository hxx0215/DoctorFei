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
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[NSUserDefaults standardUserDefaults] setObject:@(39) forKey:@"UserId"];
    // Override point for customization after application launch.
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"DoctorFei.sqlite"];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    
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
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [SetOnlineStateUtil online];
    [self setPushUser];
    [[SocketConnection sharedConnection]beginListen];
    [[SocketConnection sharedConnection]sendKeepAlive];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    [SetOnlineStateUtil offline];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [SetOnlineStateUtil offline];
    [[SocketConnection sharedConnection]stopListen];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [SetOnlineStateUtil online];
    [self setPushUser];
    [[SocketConnection sharedConnection]beginListen];
    [[SocketConnection sharedConnection]sendKeepAlive];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [APService registerDeviceToken:deviceToken];
    //使用UUID设置别名
    [APService setAlias: [DeviceUtil getUUID] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


- (void)tagsAliasCallback:(int)iResCode tags:(NSSet *)tags alias:(NSString *)alias {
    NSString *callbackString = [NSString stringWithFormat:@"%d, alias: %@\n", iResCode, alias];
    NSLog(@"TagsAlias回调:%@", callbackString);
    if (iResCode != 0){
        NSLog(@"注册别名失败");
    }
}

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

@end
