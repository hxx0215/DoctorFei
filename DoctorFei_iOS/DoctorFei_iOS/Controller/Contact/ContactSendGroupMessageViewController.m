//
//  ContactSendGroupMessageViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/14/15.
//
//

#import "ContactSendGroupMessageViewController.h"
#import "ContactViewController.h"
@interface ContactSendGroupMessageViewController ()

@end

@implementation ContactSendGroupMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ContactViewController *contact = [segue destinationViewController];
    contact.contactMode = ContactViewControllerModeGMAddFriend;
    contact.didSelectFriends = ^(NSArray *friendArr){
        NSLog(@"%@",friendArr);
    };
}


@end
