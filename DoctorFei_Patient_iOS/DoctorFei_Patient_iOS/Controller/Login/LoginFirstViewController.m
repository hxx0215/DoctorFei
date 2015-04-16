//
//  LoginFirstViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by 刘向宏 on 15-1-22.
//
//

#import "LoginFirstViewController.h"
#import "RegisterTableViewController.h"

@interface LoginFirstViewController ()
- (IBAction)userTypeButtonClicked:(id)sender;

@end

@implementation LoginFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"RegisterByType0SegueIdnetifier"]) {
//        RegisterTableViewController *vc = [segue destinationViewController];
//        [vc setUserType:@0];
//    }else if ([segue.identifier isEqualToString:@"RegisterByType1SegueIdnetifier"]) {
//        RegisterTableViewController *vc = [segue destinationViewController];
//        [vc setUserType:@1];
//    }
}

- (IBAction)userTypeButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(userTypeButtonClickedWithUserType:)]) {
        [self dismissViewControllerAnimated:NO completion:^{
            [_delegate userTypeButtonClickedWithUserType:@(((UIButton *)sender).tag)];
        }];
    }
}
@end
