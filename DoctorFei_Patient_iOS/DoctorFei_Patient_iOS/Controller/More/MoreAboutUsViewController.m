//
//  MoreAboutUsViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 12/3/14.
//
//

#import "MoreAboutUsViewController.h"
#import "MobileAPI.h"
#import <MBProgressHUD.h>
@interface MoreAboutUsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *aboutInfoTextView;
@property (weak, nonatomic) IBOutlet UILabel *aboutTitleLabel;
@end

@implementation MoreAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.aboutTitleLabel setText:[NSString stringWithFormat:@"费医生%@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = @"载入中...";
    [MobileAPI getAboutInfoWithParameters:nil succsess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [responseObject firstObject];
        if ([dict[@"state"]intValue] == 1) {
            [hud hide:YES];
//            [self.aboutInfoTextView setText:dict[@"info"]];
            NSString *htmlString = dict[@"info"];
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            self.aboutInfoTextView.attributedText = attributedString;
        }
        else{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"载入错误";
            [hud hide:YES afterDelay:1.0f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
