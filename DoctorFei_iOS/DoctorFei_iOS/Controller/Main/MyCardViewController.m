//
//  MyCardViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/24.
//
//

#import "MyCardViewController.h"
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
#import <UIImageView+WebCache.h>
@interface MyCardViewController ()

- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qRCodeImageView;

@end

@implementation MyCardViewController
{
    NSNumber *currentUserId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentUserId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    self.nameLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"];
    NSString *department = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserDepartment"];
    NSString *jobTitle = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserJobTitle"];
    self.infoLabel.text = [NSString stringWithFormat:@"%@ %@", department, jobTitle];
    NSString *qrCodeURL = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserQRCodeURL"];
    if (qrCodeURL) {
        [self.qRCodeImageView sd_setImageWithURL:[NSURL URLWithString:qrCodeURL] placeholderImage:nil options:SDWebImageRefreshCached];
    }
    [self fetchQRCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchQRCode {
    NSDictionary *params = @{
                             @"doctorid": [currentUserId stringValue]
                             };
    [DoctorAPI getQRCodeWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        if ([dataDict[@"state"]intValue] == 1) {
            NSString *qrScene = dataDict[@"qrscene"];
            [[NSUserDefaults standardUserDefaults] setObject:qrScene forKey:@"UserQRCodeURL"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.qRCodeImageView sd_setImageWithURL:[NSURL URLWithString:qrScene] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    [self.qRCodeImageView setImage:image];
                }
            }];
        }
        else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            hud.dimBackground = YES;
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"获取二维码错误";
            hud.detailsLabelText = dataDict[@"msg"];
            [hud hide:YES afterDelay:1.5f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
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
@end
