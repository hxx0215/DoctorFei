//
//  DoctorRankTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/7/15.
//
//

#import "DoctorRankTableViewController.h"
#import "DoctorRankTableViewCell.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
#import <MJRefresh.h>

#define Contact_PageSize 10
@interface DoctorRankTableViewController ()

@end

@implementation DoctorRankTableViewController
{
    MBProgressHUD *hud;
    NSMutableArray *tableViewDicArray;
    NSInteger pageIndex;
    NSInteger lastSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [UIView new];
    
    tableViewDicArray = [[NSMutableArray alloc]init];
    pageIndex = 1;
    lastSize = Contact_PageSize;
    
    __weak typeof(self) wself = self;
    [self.tableView addFooterWithCallback:^{
        typeof(self) sself = wself;
        [sself loadMore];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self searchFrind];
}

-(void)loadMore
{
    if (lastSize!=Contact_PageSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView footerEndRefreshing];
        });
        return ;//已到最后。返回
    }
    pageIndex++;
    [self searchFrind];
}

-(void)searchFrind
{
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"type": @2,
//                             @"userid": [userId stringValue],
//                             @"usertype": @2,
                             @"pageSize": @Contact_PageSize,
                             @"pageIndex": [NSNumber numberWithInteger:pageIndex]
                             };
    [DoctorAPI searchFriendWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *dataArray = (NSArray *)responseObject;
        for (NSDictionary *dict in dataArray) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
            [tableViewDicArray addObject:dic];
        }
        lastSize = [dataArray count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView footerEndRefreshing];
        });
        [self.tableView reloadData];
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView footerEndRefreshing];
        });

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [tableViewDicArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoctorRankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DoctorRankIdentifier" forIndexPath:indexPath];
    [cell setDataDic:[tableViewDicArray objectAtIndex:indexPath.row]];
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
