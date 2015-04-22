//
//  MySelfRecordListViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import "MySelfRecordListViewController.h"
#import "DoctorFei_Patient_iOS-swift.h"
#import "MemberAPI.h"
@implementation NSString(size)
- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font {
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        expectedLabelSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    
    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}
@end
@interface MySelfRecordListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
- (IBAction)backButtonClicked:(id)sender;
@property (nonatomic, strong)NSMutableArray *tableData;
@end

@implementation MySelfRecordListViewController
static NSString * const myselfRecordIdentifier = @"MySelfRecordTableViewIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:[UIView new]];
    [self.view addSubview:self.tableView];
    
    UINib *nib = [UINib nibWithNibName:@"MySelfRecordListTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:myselfRecordIdentifier];
    self.tableData = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getRecord];
    self.tableView.frame = self.view.bounds;
}

- (void)getRecord{
    NSDictionary *params = @{@"uid": [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]};
    [MemberAPI getHistoryWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@",responseObject);
        self.tableData = responseObject;
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"%@",error);
    }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MySelfRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myselfRecordIdentifier forIndexPath:indexPath];
    cell.contentLabel.text = self.tableData[indexPath.row][@"notes"];
    cell.imageUrl = self.tableData[indexPath.row][@"imgs"];
    cell.recordDate.text = self.tableData[indexPath.row][@"addtime"];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 176;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MySelfRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myselfRecordIdentifier];
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    cell.contentLabel.text = self.tableData[indexPath.row][@"notes"];
    NSString *str = self.tableData[indexPath.row][@"notes"];
    CGSize size = [str calculateSize:CGSizeMake(cell.contentLabel.frame.size.width, FLT_MAX) font:cell.contentLabel.font];
    NSArray *imgs = self.tableData[indexPath.row][@"imgs"];
    return size.height + 61 + imgs.count * 134;
}
@end
