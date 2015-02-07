//
//  MainGroupTableViewCell.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/19.
//
//

#import "MainGroupTableViewCell.h"
#import "Groups.h"
@interface MainGroupTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MainGroupTableViewCell
@synthesize currentGroup = _currentGroup;

- (void)setCurrentGroup:(Groups *)currentGroup {
    _currentGroup = currentGroup;
    _nameLabel.text = _currentGroup.title;
}

@end
