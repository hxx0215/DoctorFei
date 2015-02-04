//
//  AgendaArrangementDetailEventViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/5.
//
//

#import "AgendaArrangementDetailEventViewController.h"
#import <ReactiveCocoa.h>
@interface AgendaArrangementDetailEventViewController ()
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;

@property (weak, nonatomic) IBOutlet UITextField *eventTextField;

@end

@implementation AgendaArrangementDetailEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RAC(self.confirmButton, enabled) = [RACSignal combineLatest:@[self.eventTextField.rac_textSignal] reduce:^(NSString *string){
        return @(string.length > 0);
    }];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.eventTextField.frame.size.height)];
    leftView.backgroundColor = self.eventTextField.backgroundColor;
    self.eventTextField.leftView = leftView;
    self.eventTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.eventTextField becomeFirstResponder];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(confirmButtonClickedForAgendaArrangementDetailEventVC:eventString:)]) {
        [self.delegate confirmButtonClickedForAgendaArrangementDetailEventVC:self eventString:self.eventTextField.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
