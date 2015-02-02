//
//  MyPageContentArticleTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentArticleTableViewCell.h"
#import "DayLog.h"
#import <NSDate+DateTools.h>
@interface MyPageContentArticleTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end

@implementation MyPageContentArticleTableViewCell
@synthesize dayLog = _dayLog;

- (void)setDayLog:(DayLog *)dayLog {
    _dayLog = dayLog;
    
    [_titleLabel setText:_dayLog.title];
    [_timeLabel setText:_dayLog.createTime.timeAgoSinceNow];
    [_contentLabel setText:_dayLog.content];

}

@end
