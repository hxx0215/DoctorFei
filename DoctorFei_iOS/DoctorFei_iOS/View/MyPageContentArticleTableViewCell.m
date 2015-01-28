//
//  MyPageContentArticleTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MyPageContentArticleTableViewCell.h"

@interface MyPageContentArticleTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end

@implementation MyPageContentArticleTableViewCell
@synthesize currentDic = _currentDic;
- (void)setCurrentDic:(NSDictionary *)currentDic {
    _currentDic = currentDic;
    self.titleLabel.text = _currentDic[@"title"];
    self.contentLabel.text = _currentDic[@"content"];
    self.timeLabel.text = [self stringFromNumber:_currentDic[@"createtime"]];
}

- (NSString *)stringFromNumber:(NSNumber *)timeInterval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeInterval longValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
@end
