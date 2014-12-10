//
//  Friends+PinYinUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/9.
//
//

#import "Friends+PinYinUtil.h"
#import "pinyin.h"
@implementation Friends (PinYinUtil)

- (NSString *)getFirstCharPinYin {
    if (self.realname == nil || [self.realname isEqualToString:@""]) {
        return @"#";
    }
    if ([self.realname canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return self.realname;
    }
    else {
        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([self.realname characterAtIndex:0])];
    }
}

@end
