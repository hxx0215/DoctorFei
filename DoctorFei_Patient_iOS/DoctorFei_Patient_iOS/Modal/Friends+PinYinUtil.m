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
    NSString *actionName;
    if (self.noteName && self.noteName.length > 0) {
        actionName = self.noteName;
    }
    else{
        actionName = self.realname;
    }
    if (actionName == nil || [actionName isEqualToString:@""]) {
        return @"#";
    }
    if ([actionName canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return actionName;
    }
    else {
        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([actionName characterAtIndex:0])];
    }
}

@end
