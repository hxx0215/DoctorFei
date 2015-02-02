//
//  ShuoShuo.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/2.
//
//

#import "ShuoShuo.h"

@implementation ShuoShuo

- (instancetype)initWithShuoShuoId:(NSNumber *)shuoshuoId doctorId:(NSNumber *)doctorId title:(NSString *)title content:(NSString *)content createTime:(NSDate *)createTime {
    self = [super init];
    if (self) {
        _shuoshuoId = shuoshuoId;
        _doctorId = doctorId;
        _title = title;
        _content = content;
        _createTime = createTime;
    }
    return self;
}


@end
