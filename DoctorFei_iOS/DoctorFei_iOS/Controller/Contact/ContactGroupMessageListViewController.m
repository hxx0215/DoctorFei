//
//  ContactGroupMessageListViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/4/18.
//
//

#import "ContactGroupMessageListViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "ChatAPI.h"
#import "ContactGroupMessageTableViewCell.h"

@implementation NSString (Size)
- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font {
    CGSize expectedLabelSize = CGSizeZero;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    expectedLabelSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}

@end
@interface ContactGroupMessageListViewController ()
    <DZNEmptyDataSetSource, UITableViewDelegate, UITableViewDataSource>
- (IBAction)backButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ContactGroupMessageListViewController
{
    NSMutableArray *groupMessageArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    groupMessageArray = [NSMutableArray array];
    [self fetchGroupMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchGroupMessage {
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *param = @{
                            @"userid": doctorId,
                            @"usertype": @2
                            };
    [ChatAPI getChatGroupSendWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject firstObject][@"state"] == nil) {
            groupMessageArray = [((NSArray *)responseObject) mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
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

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groupMessageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactGroupMessageCellIdentifier = @"ContactGroupMessageCellIdentifier";
    ContactGroupMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactGroupMessageCellIdentifier forIndexPath:indexPath];
    [cell setDataDict:groupMessageArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableView Delegate

#pragma mark - DZNEmptyDatasource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无群聊信息"];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 102.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *content = groupMessageArray[indexPath.row][@"content"];
    CGSize size = [content calculateSize:CGSizeMake(self.view.bounds.size.width - 20, FLT_MAX) font:[UIFont systemFontOfSize:17.0f]];
    return size.height + 81.0f;
}
@end
