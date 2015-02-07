//
//  MainGroupSelectTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/19.
//
//

#import "MainGroupSelectTableViewCell.h"
#import "Groups.h"
@interface MainGroupSelectTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;


@end

@implementation MainGroupSelectTableViewCell
@synthesize currentGroup = _currentGroup;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [_selectButton setSelected:selected];
}

- (void)setCurrentGroup:(Groups *)currentGroup {
    _currentGroup = currentGroup;
    _nameLabel.text = _currentGroup.title;
}

@end
