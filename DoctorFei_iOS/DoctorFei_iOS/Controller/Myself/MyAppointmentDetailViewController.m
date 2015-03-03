//
//  MyAppointmentDetailViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/6/15.
//
//

#import "MyAppointmentDetailViewController.h"

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
        case AppointDetailTypeAgreeAndDisagree:
        {
            [self.agreeButton setTitle:@"同意并添加到通讯录" forState:UIControlStateNormal];
            break;
        }
        case AppointDetailTypeDisagreed:{
            self.agreeButton.hidden = YES;
            break;
        }
        case AppointDetailTypeAgreed:
            self.disagreeButton.hidden = YES;
            break;
        case AppointDetailTypeAgreeAndAdd:
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
}
- (IBAction)disagree:(id)sender {
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
