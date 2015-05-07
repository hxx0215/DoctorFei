//
//  ContactGroupRemoteDetailViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/7.
//
//

#import "ContactGroupRemoteDetailViewController.h"

@interface ContactGroupRemoteDetailViewController ()
- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
- (IBAction)joinButtonClicked:(id)sender;
@end

@implementation ContactGroupRemoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)backButtonClicked:(id)sender {
}
- (IBAction)joinButtonClicked:(id)sender {
}
@end
