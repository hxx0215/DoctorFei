//
//  ContactNearbyTableViewCell.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/13/15.
//
//

#import "ContactNearbyTableViewCell.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>

@implementation ContactNearbyTableViewCell
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
        }
        else{
            hud.mode = MBProgressHUDModeText;
        }
        hud.detailsLabelText = dic[@"msg"];//NSLocalizedString(@"好友添加成功", nil);
        [hud hide:YES afterDelay:1.0f];
        sender.enabled = NO;
        [dict setValue:@1 forKey:@"myfirend"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
    
    
}

-(void)setDataDic:(NSMutableDictionary *)dic
{
    NSArray *tagImageArray = [NSArray arrayWithObjects:@"patient_tag.png",
                              @"family-member_tag.png",
                              @"dector_tag.png",nil];
    dict = dic;
    self.nameLabel.text = dict[@"realname"];
    [self.iconImage sd_setImageWithURL:dict[@"icon"] placeholderImage:[UIImage imageNamed:@"doctor-ranking_preinstall_pic.png"]];
    self.addButton.enabled = ![dic[@"myfirend"] integerValue];
    CGFloat dist = [dic[@"distance"] floatValue];
    self.distanceLabel.text = dist > 1000.0?[NSString stringWithFormat:@"%.2lfkm",dist / 1000.0] : [NSString stringWithFormat:@"%.lfm", dist];
    [self.typeImage setImage:[UIImage imageNamed:[tagImageArray objectAtIndex:[dic[@"usertype"] integerValue]]]];
}
@end
