//
//  AgendaSchedule.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/5.
//
//

#import <Foundation/Foundation.h>

@interface AgendaArrangement : NSObject
@property (nonatomic, strong) NSNumber *arrangeId;
@property (nonatomic, strong) NSString *memberName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *dayTime;
@property (nonatomic, strong) NSNumber *memberId;
@property (nonatomic, strong) NSNumber *allowTip;
@property (nonatomic, strong) NSNumber *tipType;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSDate *tipTime;

@end
