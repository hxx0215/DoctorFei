//
//  ContactNewFriendTableViewCell.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/12/15.
//
//

#import "ContactNewFriendTableViewCell.h"

@implementation ContactNewFriendTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)accept:(UIButton *)sender {
    NSLog(@"同意");
}

@end
