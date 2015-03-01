//
//  DoctorRankTableViewCell.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/8/15.
//
//

#import "DoctorRankTableViewCell.h"
#import "MBProgressHUD.h"
#import <UIImageView+WebCache.h>
@implementation DoctorRankTableViewCell
{
    NSDictionary *dict;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)addFriendClicked:(UIButton *)sender {
    UIImageView *completeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_prompt-01_pic.png"]];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.dimBackground = YES;
    hud.customView = completeImage;
    hud.labelText = NSLocalizedString(@"好友添加成功", nil);
    [hud hide:YES afterDelay:2.0];
    sender.enabled = NO;
}

-(void)setDataDic:(NSDictionary *)dic
{
    dict = [dic copy];
    self.nameLabel.text = dict[@"realname"];
    [self.iconImage sd_setImageWithURL:dict[@"icon"] placeholderImage:[UIImage imageNamed:@"doctor-ranking_preinstall_pic.png"]];
}
@end
