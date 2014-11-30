//
//  DeviceUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

#import "DeviceUtil.h"
#import <UIKit/UIDevice.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation DeviceUtil
+ (NSString *)getDeviceModalDescription
{
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    if ([hardware isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([hardware isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (CDMA)";
    if ([hardware isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([hardware isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([hardware isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (GSM+Cellular)";
    if ([hardware isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (GSM+Cellular)";
    
    
    
    if ([hardware isEqualToString:@"iPod1,1"]) return @"iPod Touch (1 Gen)";
    if ([hardware isEqualToString:@"iPod2,1"]) return @"iPod Touch (2 Gen)";
    if ([hardware isEqualToString:@"iPod3,1"]) return @"iPod Touch (3 Gen)";
    if ([hardware isEqualToString:@"iPod4,1"]) return @"iPod Touch (4 Gen)";
    if ([hardware isEqualToString:@"iPod5,1"]) return @"iPod Touch (5 Gen)";
    
    if ([hardware isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([hardware isEqualToString:@"iPad1,2"]) return @"iPad 3G";
    if ([hardware isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
    if ([hardware isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,5"]) return @"iPad Mini (WiFi)";
    if ([hardware isEqualToString:@"iPad2,6"]) return @"iPad Mini";
    if ([hardware isEqualToString:@"iPad2,7"]) return @"iPad Mini (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPad3,1"]) return @"iPad 3 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,2"]) return @"iPad 3 (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([hardware isEqualToString:@"iPad3,4"]) return @"iPad 4 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,5"]) return @"iPad 4";
    if ([hardware isEqualToString:@"iPad3,6"]) return @"iPad 4 (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPad4,1"]) return @"iPad Air (WiFi)";
    if ([hardware isEqualToString:@"iPad4,2"]) return @"iPad Air (WiFi+Cellular)";
    if ([hardware isEqualToString:@"iPad4,3"]) return @"iPad Air (WiFi+TD-LTE)";
    if ([hardware isEqualToString:@"iPad4,4"]) return @"iPad Mini 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad4,5"]) return @"iPad Mini 2 (WiFi+Cellular)";
    if ([hardware isEqualToString:@"iPad4,6"]) return @"iPad Mini 2 (WiFi+TD-LTE)";
    
    if ([hardware isEqualToString:@"i386"]) return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"]) return @"Simulator";
    
    return nil;
    
}

+ (NSString *)getUUID
{
    return [[[[UIDevice currentDevice]identifierForVendor] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end
