//
//  MoreFeedbackViewController.m
//  DoctorFei_iOS
//
//  Created by 刘向宏 on 14-12-4.
//
//

#import "MoreFeedbackViewController.h"

@interface MoreFeedbackViewController ()
@property (strong, nonatomic) IBOutlet UITextView *feedbackContent;

@end

@implementation MoreFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.feedbackContent.layer.borderWidth = 1.0;
    self.feedbackContent.layer.borderColor = [UIColor colorWithWhite:213.0/255.0 alpha:1.0].CGColor;
    self.feedbackContent.layer.cornerRadius = 7.0;
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sendButtonClicked:(id)sender {
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
