//
//  MainGroupPopoverViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import "MainGroupPopoverViewController.h"
#import "MainGroupPopoverTableViewCell.h"
#import "DoctorAPI.h"
#import "Groups.h"
#import "Friends.h"
@interface MainGroupPopoverViewController ()
    <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)editButtonClicked:(id)sender;

@end

@implementation MainGroupPopoverViewController
{
    NSArray *groupArray;
}
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.preferredContentSize = CGSizeMake(180.0f, 81.0f);
    groupArray = [NSArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tableViewReloadData];
}

#pragma mark - Actions

- (void)tableViewReloadData {
    groupArray = [Groups MR_findAll];
    [self.tableView reloadData];
}

- (IBAction)editButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(editButtonClickedForPopoverVC:)]) {
        [_delegate editButtonClickedForPopoverVC:self];
    }
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + groupArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MainGroupPopoverCellIdentifier = @"MainGroupPopoverCellIdentifier";
    MainGroupPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainGroupPopoverCellIdentifier forIndexPath:indexPath];
    if (indexPath.row > 0) {
        Groups *group = groupArray[indexPath.row - 1];
        [cell.contentLabel setText:[NSString stringWithFormat:@"%@ ( %d )", group.title, group.total.intValue]];
    } else {
        NSNumber *friendCount = [Friends MR_numberOfEntities];
        if (friendCount.intValue > 0) {
            [cell.contentLabel setText:[NSString stringWithFormat:@"全部 ( %d )", friendCount.intValue]];
        }
        else{
            [cell.contentLabel setText:@"全部"];
        }
    }
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Groups *clickedGroup = nil;
    if (indexPath.row > 0) {
        clickedGroup = groupArray[indexPath.row - 1];
    }
    if ([self.delegate respondsToSelector:@selector(groupCellSelectedForPopoverVC:withGroup:)]) {
        [self.delegate groupCellSelectedForPopoverVC:self withGroup:clickedGroup];
    }
}
@end
