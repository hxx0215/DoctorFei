//
//  ContactRecordTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/21/15.
//
//

#import "ContactRecordTableViewController.h"
#import "ContactRecordTableViewCell.h"

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
@interface ContactRecordTableViewController ()
@property (nonatomic, strong)NSMutableArray *tableData;
@end

@implementation ContactRecordTableViewController
static NSString * const contactRecordIdentifier = @"ContactRecordIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([ContactRecordTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:contactRecordIdentifier];
    self.tableData = [@[@"12321312312312312",@"a\nb\nc\nd\n",@"112321321111111111231213123123123212312312312312112321321111111111231213123123123212312312312312",@"2",@"3",@"55213"] mutableCopy];
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
    return self.tableData.count;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 176;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactRecordTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:contactRecordIdentifier];
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    cell.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cell.contentLabel.text = self.tableData[indexPath.row];
    NSString *str = self.tableData[indexPath.row];
    CGSize size = [str calculateSize:CGSizeMake(cell.contentLabel.frame.size.width, FLT_MAX) font:cell.contentLabel.font];
    return size.height + 61 + indexPath.row * 134;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactRecordTableViewCell *cell = (ContactRecordTableViewCell*)[tableView dequeueReusableCellWithIdentifier:contactRecordIdentifier forIndexPath:indexPath];
    cell.contentLabel.text = self.tableData[indexPath.row];
    // Configure the cell...
    NSString *url = @"http://my.csdn.net/uploads/201206/23/1340437873_8307.png";
    NSMutableArray *ma = [NSMutableArray new];
    for (int i=0;i<indexPath.row;i++)
        [ma addObject:[url copy]];
    cell.imageUrl = ma;
    return cell;
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
