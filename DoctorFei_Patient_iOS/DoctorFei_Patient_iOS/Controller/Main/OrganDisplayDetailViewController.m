//
//  OrganDisplayDetailViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/27.
//
//

#import "OrganDisplayDetailViewController.h"
#import "MemberAPI.h"
@interface OrganShareView :UIView
@end
@implementation OrganShareView
@end
@interface OrganDisplayDetailViewController ()
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *content;

@end

@implementation OrganDisplayDetailViewController

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
    self.content.text = @"";
    NSDictionary *params = @{@"id": self.ID};
    switch (self.type){
        case OrganTypeShow:{
            [MemberAPI getOrgListWithParameters:params success:^(AFHTTPRequestOperation *operation,id responseObject){
                self.content.text = [[responseObject firstObject] objectForKey:@"des"];
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
            }];
            break;
        }
        case OrganTypeNursing:{
            [MemberAPI getNursingWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
                self.content.text = [[responseObject firstObject] objectForKey:@"des"];
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
            }];
            break;
        }
        case OrganTypeOutstanding:{
            [MemberAPI getOutStandingSampleWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
                self.content.text = [[responseObject firstObject] objectForKey:@"des"];
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
            }];
            break;
        }
        default:
            break;
    }
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
