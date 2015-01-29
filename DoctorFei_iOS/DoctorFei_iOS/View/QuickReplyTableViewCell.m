//
//  QuickReplyTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/28.
//
//

#import "QuickReplyTableViewCell.h"

@interface QuickReplyTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;


@end

@implementation QuickReplyTableViewCell
@synthesize replyContent = _replyContent;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [_selectButton setSelected:selected];
}

- (void)setReplyContent:(NSString *)replyContent {
    _replyContent = replyContent;
    [_contentLabel setText:_replyContent];
}

@end
