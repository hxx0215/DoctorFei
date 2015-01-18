//
//  MainGroupPopoverViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MainGroupPopoverViewController.h"
#import "MainGroupPopoverTableViewCell.h"
@interface MainGroupPopoverViewController ()
    <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)editButtonClicked:(id)sender;

@end

@implementation MainGroupPopoverViewController
@synthesize delegate = _delegate;

#pragma mark - Actions
- (IBAction)editButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(editButtonClickedForPopoverVC:)]) {
        [_delegate editButtonClickedForPopoverVC:self];
    }
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MainGroupPopoverCellIdentifier = @"MainGroupPopoverCellIdentifier";
    MainGroupPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainGroupPopoverCellIdentifier forIndexPath:indexPath];
    [cell.contentLabel setText:@"全部(123)"];
    return cell;
}

#pragma mark - UITableView Delegate
@end
