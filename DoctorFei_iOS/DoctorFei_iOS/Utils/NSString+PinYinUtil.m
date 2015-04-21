//
//  NSString+PinYinUtil.m
//  DoctorFei_iOS
//
//  Created by shadowPriest on 4/20/15.
//
//

#import "NSString+PinYinUtil.h"
#import "pinyin.h"
@implementation NSString (PinYinUtil)
- (NSString *)getFirstCharPinYin {
    NSString *actionName;
    if (self && self.length > 0) {
        actionName = self;
    }
    else{
        actionName = @"";
    }
    if (actionName == nil || [actionName isEqualToString:@""]) {
        return @"{";
    }
    if ([actionName canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return [NSString stringWithFormat:@"%c",[actionName characterAtIndex:0]];
    }
    else {
        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([actionName characterAtIndex:0])];
    }
}
@end
