//
//  AgendaViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/13.
//
//

#import "AgendaViewController.h"

@interface AgendaViewController ()
- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *contentView;
- (IBAction)segmentValueChanged:(id)sender;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;
@end

@implementation AgendaViewController
@synthesize segmentControl = _segmentControl;
@synthesize contentView = _contentView;
@synthesize viewControllers = _viewControllers;
@synthesize currentViewController = _currentViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewControllers = @[
                         [self.storyboard instantiateViewControllerWithIdentifier:@"AgendaTimeScheduleViewController"],
                         [self.storyboard instantiateViewControllerWithIdentifier:@"AgendaArrangementTableViewController"]
                         ];
    _segmentControl.selectedSegmentIndex = 0;
    
    [self showViewController:_viewControllers[0] animated:NO];

}

- (void)showViewController:(UIViewController *)aViewController animated:(BOOL)animated {
    if (!aViewController) {
        return;
    }
    if (aViewController != _currentViewController) {
        aViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        __weak AgendaViewController *blockSelf = self;
        void(^switchViewController)(void) = ^() {
            [blockSelf showViewControllerWithSlideInAnimation: aViewController];
            blockSelf.currentViewController = aViewController;
            blockSelf.segmentControl.selectedSegmentIndex = [blockSelf.viewControllers indexOfObject:aViewController];
        };
        
        if (self.currentViewController && [aViewController isViewLoaded] && animated) {
            switchViewController();
        } else {
            aViewController.view.frame = CGRectMake(0, 0, blockSelf.view.frame.size.width, blockSelf.view.frame.size.height);
            switchViewController();
        }
        
        [blockSelf.navigationItem setRightBarButtonItems:aViewController.navigationItem.rightBarButtonItems animated:animated];
    }
}
- (void)showViewControllerWithSlideInAnimation: (UIViewController *)aViewController {
    NSInteger oldIndex = _currentViewController ? [_viewControllers indexOfObject:_currentViewController] : NSNotFound;
    NSInteger newIndex = [_viewControllers indexOfObject:aViewController];
    BOOL slideFromLeft = oldIndex >= newIndex;
    BOOL animationRunning = [_contentView.layer.animationKeys count] > 0 ? YES : NO;
    
    [_currentViewController willMoveToParentViewController:nil];
    [aViewController willMoveToParentViewController:self];
    [_contentView addSubview:aViewController.view];
    [self addChildViewController:aViewController];
    
    [aViewController didMoveToParentViewController:self];
    
    __block CGRect aViewControllerRect = _contentView.bounds;
    if (slideFromLeft) {
        aViewControllerRect.origin.x = - _currentViewController.view.frame.size.width;
    } else {
        aViewControllerRect.origin.x = self.view.frame.size.width;
    }
    
    aViewController.view.frame = aViewControllerRect;
    
    __block CGRect currentViewControllerRect = _currentViewController.view.frame;
    if(slideFromLeft) {
        currentViewControllerRect.origin.x = self.view.frame.size.width;
    } else {
        currentViewControllerRect.origin.x = - _currentViewController.view.frame.size.width;
    }
    
    __block UIViewController *oldViewController = _currentViewController;
    [UIView animateWithDuration:0.3 delay:0 options:(animationRunning ? UIViewAnimationOptionBeginFromCurrentState : 0) animations:^{
        _currentViewController.view.frame = currentViewControllerRect;
        aViewControllerRect.origin.x = 0;
        aViewController.view.frame = aViewControllerRect;
    } completion:^(BOOL finished) {
        [oldViewController removeFromParentViewController];
        if (finished) {
            [oldViewController.view removeFromSuperview];
        }
        [oldViewController didMoveToParentViewController:nil];
    }];
}

- (IBAction)segmentValueChanged:(id)sender {
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
    [self showViewController:_viewControllers[segmentControl.selectedSegmentIndex] animated:YES];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
