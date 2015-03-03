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
#import "DoctorAPI.h"
@implementation DoctorRankTableViewCell
{
    NSMutableDictionary *dict;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)addFriendClicked:(UIButton *)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"usertype": dict[@"usertype"],
                             @"doctorid": [userId stringValue],
                             @"friendid": dict[@"userid"]
                             };
    [DoctorAPI addFriendWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"addFriend: %@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        if ([dic[@"state"] integerValue]==1) {
            UIImageView *completeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_prompt-01_pic.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.dimBackground = YES;
            hud.customView = completeImage;
            [dict setValue:@1 forKey:@"myfirend"];
        }
        hud.labelText = dic[@"msg"];//NSLocalizedString(@"好友添加成功", nil);
        [hud hide:YES afterDelay:2.0];
        sender.enabled = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
    
    
}

-(void)setDataDic:(NSMutableDictionary *)dic
{
    dict = dic;
    self.nameLabel.text = dict[@"realname"];
    [self.iconImage sd_setImageWithURL:dict[@"icon"] placeholderImage:[UIImage imageNamed:@"doctor-ranking_preinstall_pic.png"]];
    self.addButton.enabled = ![dic[@"myfirend"] integerValue];
}
@end
