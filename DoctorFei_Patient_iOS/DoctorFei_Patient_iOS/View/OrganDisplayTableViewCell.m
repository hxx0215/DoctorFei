//
//  OrganDisplayTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/27.
//
//

#import "OrganDisplayTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "NSString+Crypt.h"
@interface OrganDisplayTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *hospitalName;
@property (weak, nonatomic) IBOutlet UILabel *officeOrg;
@property (weak, nonatomic) IBOutlet UIImageView *hospitalImage;
@property (weak, nonatomic) IBOutlet UILabel *rate;

@end
@implementation OrganDisplayTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellData:(NSDictionary *)data{
    self.hospitalName.text = [data objectForKey:@"name"];
    self.officeOrg.text = [data objectForKey:@"officeorg"];
    [self.hospitalImage sd_setImageWithURL:[NSURL URLWithString:[[data objectForKey:@"picture"] urlAutoCompelete]]placeholderImage:[UIImage imageNamed:@"hospital_pic.png"]];
    self.rate.text = @"";
}
@end
