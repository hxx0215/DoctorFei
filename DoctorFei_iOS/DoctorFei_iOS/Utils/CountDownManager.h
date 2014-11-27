//
//  CountDownManager.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/26.
//
//

#import <Foundation/Foundation.h>

@interface CountDownManager : NSObject

+ (id)sharedManager;

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) int count;

@end
