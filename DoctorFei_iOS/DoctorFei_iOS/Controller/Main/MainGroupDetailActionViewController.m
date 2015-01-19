//
//  MainGroupDetailActionViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/19.
//
//

#import "MainGroupDetailActionViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "MainGroupTableViewCell.h"
#import "MainGroupSelectTableViewCell.h"
@interface MainGroupDetailActionViewController ()
    <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainGroupDetailActionViewController
@synthesize vcMode = _vcMode;


- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect tableViewHeaderFrame = self.tableView.tableHeaderView.frame;
    if (_vcMode == MainGroupDetailActionViewControllerModeEdit) {
        _title = @"编辑分组";
        tableViewHeaderFrame.size.height = 41.0f;
        self.navigationItem.rightBarButtonItems = nil;
    }
    else{
        _title = @"选择分组";
        tableViewHeaderFrame.size.height = 0.0f;
        self.navigationItem.leftBarButtonItems = nil;
    }
    [self.tableView.tableHeaderView setFrame:tableViewHeaderFrame];
}


#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES
     ];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO
    return nil;
}
#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41.0f;
}
#pragma mark - DZNEmptyDataSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    return [[NSAttributedString alloc]initWithString:@"暂无分组"];
}

@end
