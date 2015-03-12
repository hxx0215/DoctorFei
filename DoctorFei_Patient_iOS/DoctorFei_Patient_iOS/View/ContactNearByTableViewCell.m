//
//  ContactNearyByTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/12.
//
//

#import "ContactNearByTableViewCell.h"
#import <UIImageView+WebCache.h>
@interface ContactNearByTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@end

@implementation ContactNearByTableViewCell

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    [_nameLabel setText:_dataDict[@"realname"]];
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_dataDict[@"icon"]] placeholderImage:[UIImage imageNamed:@"doctor-ranking_preinstall_pic"]];
    [_addButton setHidden:[_dataDict[@"myfriend"]intValue]];
    [_stateLabel setHidden:![_dataDict[@"myfriend"]intValue]];
    [_distanceLabel setText:[NSString stringWithFormat:@"%ldm", [_dataDict[@"distance"] longValue]]];
    NSArray *imageArray = @[@"patient_tag.png",
                            @"family-member_tag.png",
                            @"dector_tag.png"];
    [_typeImageView setImage:[UIImage imageNamed:imageArray[[_dataDict[@"usertype"] intValue]]]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
