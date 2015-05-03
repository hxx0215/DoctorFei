//
//  ContactGroupNewLocationTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/3.
//
//

#import "ContactGroupNewLocationTableViewCell.h"

@implementation ContactGroupNewLocationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.selectedButton setHidden:!selected];
    [self.nameLabel setHighlighted:selected];
    [self.addressLabel setHighlighted:selected];
    // Configure the view for the selected state
}

@end
