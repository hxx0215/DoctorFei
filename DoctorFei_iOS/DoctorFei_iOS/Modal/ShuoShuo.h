//
//  ShuoShuo.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/2.
//
//

#import <Foundation/Foundation.h>

@interface ShuoShuo : NSObject

@property (nonatomic, strong) NSNumber *shuoshuoId;
@property (nonatomic, strong) NSNumber *doctorId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *createTime;


- (instancetype)initWithShuoShuoId:(NSNumber *)shuoshuoId doctorId:(NSNumber *)doctorId title:(NSString *)title content:(NSString *)content createTime:(NSDate *)createTime;
@end
