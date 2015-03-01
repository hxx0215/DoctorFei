//
//  MoreUpdateViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 12/4/14.
//
//

#import "MoreUpdateViewController.h"
#import "MobileAPI.h"
#import "JSONKit.h"

@interface MoreUpdateViewController ()
@property (nonatomic, strong)NSArray *versions;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) NSDictionary *versionData;
@end

@implementation MoreUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versions = [app_Version componentsSeparatedByString:@"."];
//    NSLog(@"%@",app_Version);
    [self fetchMobileVersion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)updateButtonClicked:(id)sender {
}

- (void)fetchMobileVersion{
    NSDictionary *params = @{@"mobiletype": @(2)};
    [MobileAPI getMobileVersionWithParameters:params succsess:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject count]<1)
        {
            [self haveNewVersion:NO];
            return ;
        }
        NSString *newestVersion = [NSString stringWithFormat:@"%@",responseObject[0][@"versions"]];
        self.versionData = responseObject[0];
        NSArray *newestVersionList = [newestVersion componentsSeparatedByString:@"."];
        NSInteger length = MIN([newestVersionList count], [self.versions count]);
        for (int i=0;i<length;i++){
            NSInteger now = [self.versions[i] integerValue];
            NSInteger online = [newestVersionList[i] integerValue];
            if (now == online) continue;
            [self haveNewVersion:now<online];
            return ;
        }
        [self haveNewVersion:NO];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
    }];
}
- (void)haveNewVersion:(BOOL)haveNew{
    if (haveNew){
        self.statusLabel.text = [NSString stringWithFormat:@"已有新版本:%@",self.versionData[@"name"]];
        [self.updateButton addTarget:self action:@selector(upgrade:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.statusLabel.text = NSLocalizedString(@"当前已是最新版本", nil);
        [self.updateButton setEnabled:NO];
    }
}
- (void)upgrade:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.versionData[@"url"]]];
}
@end
