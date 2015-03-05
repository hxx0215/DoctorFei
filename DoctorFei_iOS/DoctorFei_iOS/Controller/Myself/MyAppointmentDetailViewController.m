//
//  MyAppointmentDetailViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/6/15.
//
//

#import "MyAppointmentDetailViewController.h"
#import "DoctorAPI.h"
#import "MBProgressHUD.h"
@interface MyAppointmentDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *disagreeButton;

@end

@implementation MyAppointmentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.dateLabel.text = self.date;
    self.contentText.text =self.content;
    switch (self.flag) {
        case AppointDetailTypeNoButton:
            self.agreeButton.hidden = YES;
            self.disagreeButton.hidden = YES;
            break;
        case AppointDetailTypeAgreeAndAdd:
        {
            [self.agreeButton setTitle:@"同意并添加到通讯录" forState:UIControlStateNormal];
            break;
        }
        case AppointDetailTypeDisagreed:{
            self.agreeButton.enabled = NO;
            self.disagreeButton.hidden =YES;
            [self.agreeButton setTitle:@"已拒绝" forState:UIControlStateNormal];
            break;
        }
        case AppointDetailTypeAgreed:
            self.disagreeButton.hidden = YES;
            self.agreeButton.enabled = NO;
            [self.agreeButton setTitle:@"已同意" forState:UIControlStateNormal];
            break;
        case AppointDetailTypeAgreeAndDisagree:
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)agree:(id)sender {
    if (self.flag == AppointDetailTypeAgreeAndAdd)
        [self auditReferral:YES];
    else
        [self auditAppointment:YES];
}
- (IBAction)disagree:(id)sender {
    if (self.flag == AppointDetailTypeAgreeAndAdd)
        [self auditReferral:NO];
    else
        [self auditAppointment:NO];
}

-(void)auditReferral:(BOOL)flag{
    NSDictionary *params = @{@"doctorid": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"],
                             @"referralid": self.ID,
                             @"type" : flag ? @(1):@(2)};
    [DoctorAPI AuditReferralWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@",responseObject);
        NSString *msg = [[responseObject firstObject] objectForKey:@"msg"];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText =msg;
        hud.dimBackground = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"%@",error);
    }];
}

-(void)auditAppointment:(BOOL)flag{
    NSDictionary *params = @{@"doctorid": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"],
                             @"appid": self.ID,
                             @"type" : flag ? @(1):@(2)};
    [DoctorAPI setAppointmentWithParameters:params success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSLog(@"%@",responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",error);
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

@end
