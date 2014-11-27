//
//  CountDownManager.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/26.
//
//

#import "CountDownManager.h"

@implementation CountDownManager

@synthesize countDownTimer = _countDownTimer;
@synthesize count = _count;

+ (id)sharedManager
{
    static CountDownManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
    });
    return sharedManager;
}

- (id)init
{
    if (self = [super init]) {
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCountDown) userInfo:nil repeats:YES];
        _count = 60;
    }
    return self;
}


- (void)timeCountDown
{
    _count--;
}

@end
