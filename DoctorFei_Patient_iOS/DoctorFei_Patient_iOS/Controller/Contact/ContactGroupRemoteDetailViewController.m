//
//  ContactGroupRemoteDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/7.
//
//

#import "ContactGroupRemoteDetailViewController.h"
#import "ChatAPI.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface ContactGroupRemoteDetailViewController ()
- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
- (IBAction)joinButtonClicked:(id)sender;
@end

@implementation ContactGroupRemoteDetailViewController
{
    NSDictionary *infoDict;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchGroupInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)reloadUIViews {
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:infoDict[@"icon"]] placeholderImage:[UIImage imageNamed:@"group_preinstall_pic"]];
    [_nameLabel setText:[NSString stringWithFormat:@"%@ (%@)", infoDict[@"name"], [infoDict[@"total"] stringValue]]];
    [_distanceLabel setText:[NSString stringWithFormat:@"%@m", infoDict[@"distance"]]];
    if ([infoDict[@"address"] isKindOfClass:[NSString class]]) {
        [_addressLabel setText:infoDict[@"address"]];
    }else{
        [_addressLabel setText:@""];
    }
    [_introTextView setText:infoDict[@"note"]];
    [self.joinButton setHidden: ([infoDict[@"injoin"]intValue] == 1)];
}

- (void)fetchGroupInfo {
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"groupid": _groupId,
                            @"userid": userId,
                            @"usertype": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"],
                            @"lng": _longtitude,
                            @"lat": _latitude
                            };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"载入中...";
    [ChatAPI getGroupInfoWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        infoDict = [responseObject firstObject];
        [hud hide:NO];
        [self reloadUIViews];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)postJoinGroup {
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{@"groupid": _groupId,
                            @"userid": userId,
                            @"usertype": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"]};
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"提交中..";
    [ChatAPI joinGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        hud.mode = MBProgressHUDModeText;
        NSDictionary *result = [responseObject firstObject];
        hud.labelText = result[@"msg"];
        [hud hide:YES afterDelay:1.0f];
        if ([result[@"state"] intValue] == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)joinButtonClicked:(id)sender {
    [self postJoinGroup];
}
@end
