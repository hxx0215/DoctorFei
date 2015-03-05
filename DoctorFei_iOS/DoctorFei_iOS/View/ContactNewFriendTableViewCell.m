//
//  ContactNewFriendTableViewCell.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/12/15.
//
//

#import "ContactNewFriendTableViewCell.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>

@implementation ContactNewFriendTableViewCell
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
- (IBAction)accept:(UIButton *)sender {
    NSLog(@"同意");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"usertype": dict[@"usertype"],
                             @"userid": [userId stringValue],
                             @"id": dict[@"id"],
                             @"type": @1
                             };
    [DoctorAPI setFriendInvitationWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"setFriendInvitation: %@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        if ([dic[@"state"] integerValue]==1) {
            UIImageView *completeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_prompt-01_pic.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.dimBackground = YES;
            hud.customView = completeImage;
        }
        hud.labelText = dic[@"msg"];//NSLocalizedString(@"好友添加成功", nil);
        [hud hide:YES afterDelay:2.0];
        sender.enabled = NO;
        [dict setValue:@1 forKey:@"isaudit"];
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
    self.nameLabel.text = dict[@"RealName"];
    [self.iconImage sd_setImageWithURL:dict[@"icon"] placeholderImage:[UIImage imageNamed:@"doctor-ranking_preinstall_pic.png"]];
    self.addButton.enabled = ![dic[@"isaudit"] integerValue];
}
@end
