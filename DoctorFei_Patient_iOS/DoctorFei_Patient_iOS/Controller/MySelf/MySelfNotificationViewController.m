//
//  MySelfNotificationViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import "MySelfNotificationViewController.h"
#import "MemberAPI.h"
@interface MySelfNotificationViewController ()
- (IBAction)backButtonClicked:(id)sender;

@end

@implementation MySelfNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
}
- (void)refreshData{
    NSDictionary *params = @{@"userid":[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]};
    [MemberAPI notificationListWithParameters:params success:^(AFHTTPRequestOperation *operation,id responseObject){
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
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
