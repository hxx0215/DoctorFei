//
//  DayLog.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/2.
//
//

#import "DayLog.h"

@implementation DayLog

- (instancetype)initWithDayLogId:(NSNumber *)dayLogId doctorId:(NSNumber *)doctorId title:(NSString *)title content:(NSString *)content createTime:(NSDate *)createTime {
    self = [super init];
    if (self) {
        _dayLogId = dayLogId;
        _doctorId = doctorId;
        _title = title;
        _content = content;
        _createTime = createTime;
    }
    return self;
}

@end
