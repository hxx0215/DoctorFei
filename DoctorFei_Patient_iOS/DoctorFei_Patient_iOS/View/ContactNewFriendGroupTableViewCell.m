//
//  ContactNewFriendGroupTableViewCell.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/6/13.
//
//

#import "ContactNewFriendGroupTableViewCell.h"
#import "MBProgressHUD.h"
#import "ChatAPI.h"

@implementation ContactNewFriendGroupTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setDict:(NSDictionary *)dict {
    _dict = dict;
    _nameLabel.text = _dict[@"name"];
    _descLabel.text = _dict[@"msg"];
    if ([_dict[@"isaudit"] intValue] == 0) {
        [_agreeLabel setHidden:YES];
        [_agreeButton setHidden:NO];
    }
    else {
        [_agreeLabel setHidden:NO];
        [_agreeButton setHidden:YES];
    }
}

- (IBAction)agreeButtonClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    NSDictionary *param = @{@"rid": _dict[@"id"],
                            @"isaudit": @1};
    [ChatAPI setChatAuditWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSDictionary *result = [responseObject firstObject];
        if ([result[@"state"]intValue] == 1) {
            [sender setHidden:YES];
            [_agreeLabel setHidden:NO];
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = result[@"msg"];
        }
        [hud hide:YES afterDelay:1.5f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"提示";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
@end
