//
//  MainTabBarViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "MainTabBarViewController.h"
@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UITabBar appearance]setTintColor:UIColorFromRGB(0x6EA800)];
    
    for (UITabBarItem *item in self.tabBar.items) {
        int index = (int)[self.tabBar.items indexOfObject:item];
//        UIImage *unselect = [UIImage imageNamed:[NSString stringWithFormat:@"tab_0%lu", index + 1]];
        UIImage *select = [UIImage imageNamed:[NSString stringWithFormat:@"tab_0%d_after", index + 1]];
//        [item setImage:[unselect imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item setSelectedImage:[select imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"] == nil) {
        [self performSegueWithIdentifier:@"LoginSegueIdentifier" sender:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
