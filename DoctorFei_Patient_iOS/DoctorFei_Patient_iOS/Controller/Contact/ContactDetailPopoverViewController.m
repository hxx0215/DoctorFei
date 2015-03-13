//
//  ContactDetailPopoverViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/28.
//
//

#import "ContactDetailPopoverViewController.h"

@interface ContactDetailPopoverViewController ()
@property (weak, nonatomic) IBOutlet UIButton *hisPageBtn;
@property (weak, nonatomic) IBOutlet UIButton *departTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *launchAppointmentBtn;

@end

@implementation ContactDetailPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.hisPageBtn addTarget:self.target action:self.showHisPage forControlEvents:UIControlEventTouchUpInside];
    [self.departTimeBtn addTarget:self.target action:self.departTime forControlEvents:UIControlEventTouchUpInside];
    [self.launchAppointmentBtn addTarget:self.target action:self.launchAppointment forControlEvents:UIControlEventTouchUpInside];
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
