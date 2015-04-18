//
//  ContactGroupMessageTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/4/18.
//
//

#import "ContactGroupMessageTableViewCell.h"

@interface ContactGroupMessageTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *receiveCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@end

@implementation ContactGroupMessageTableViewCell


- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    [_receiveCountLabel setText:[NSString stringWithFormat:@"%d个收件人", [_dataDict[@"total"] intValue]]];
    [_titleLabel setText:_dataDict[@"title"]];
    [_contentLabel setText:_dataDict[@"content"]];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
