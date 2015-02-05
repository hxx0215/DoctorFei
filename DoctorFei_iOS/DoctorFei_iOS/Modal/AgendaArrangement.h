//
//  AgendaSchedule.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/5.
//
//

#import <Foundation/Foundation.h>

@interface AgendaArrangement : NSObject

@property (nonatomic, strong) NSString *memberName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *dayTime;
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *allowTip;
@property (nonatomic, strong) NSNumber *tipType;


@end
