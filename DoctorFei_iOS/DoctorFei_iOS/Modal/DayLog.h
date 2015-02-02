//
//  DayLog.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/2.
//
//

#import <Foundation/Foundation.h>

@interface DayLog : NSObject

@property (nonatomic, strong) NSNumber *dayLogId;
@property (nonatomic, strong) NSNumber *doctorId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *createTime;

- (instancetype)initWithDayLogId:(NSNumber *)dayLogId doctorId:(NSNumber *)doctorId title:(NSString *)title content:(NSString *)content createTime:(NSDate *)createTime;

@end
