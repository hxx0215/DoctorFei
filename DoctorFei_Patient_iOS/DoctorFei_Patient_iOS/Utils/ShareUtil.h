//
//  ShareUtil.h
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/22/15.
//
//

#import <Foundation/Foundation.h>
typedef enum shareType{
    shareTypeWeibo,
    shareTypeTencentWeibo
}shareType;
@interface ShareUtil : NSObject
+ (instancetype)sharedShareUtil;
- (void)shareTo:(shareType)type content:(NSDictionary *)content;
@end
