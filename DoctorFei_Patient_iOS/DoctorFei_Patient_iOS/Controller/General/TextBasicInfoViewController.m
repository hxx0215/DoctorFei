//
//  TextBasicInfoViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import "TextBasicInfoViewController.h"
#import <ReactiveCocoa.h>
@interface TextBasicInfoViewController ()
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *infoTextField;
@end

@implementation TextBasicInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[_infoTextField.rac_textSignal] reduce:^(NSString *info){
        return @(info.length > 0);
    }];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.infoTextField.frame.size.height)];
    leftView.backgroundColor = self.infoTextField.backgroundColor;
    self.infoTextField.leftView = leftView;
    self.infoTextField.leftViewMode = UITextFieldViewModeAlways;

    self.title = _titleString;
    [_infoTextField setText:_valueString];
    [_infoTextField setPlaceholder:_placeHolderString];
    [_infoTextField setKeyboardType:_keyboardType];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.infoTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.infoTextField resignFirstResponder];
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

- (IBAction)confirmButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(textBasicInfoVC:didClickedConfirmButtonWithText:)]) {
        [_delegate textBasicInfoVC:self didClickedConfirmButtonWithText:_infoTextField.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
