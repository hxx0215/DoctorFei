//
//  MySelfRootTableViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/5/15.
//
//

#import "MySelfRootTableViewController.h"
#import <UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import "DoctorAPI.h"

@interface MySelfRootTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *approveImage;
@property (weak, nonatomic) IBOutlet UILabel *approveLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointmentNums;
@property (weak, nonatomic) IBOutlet UISwitch *isVisibleNearby;

@end

@implementation MySelfRootTableViewController
{
    NSString *_icon,*_name;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.appointmentNums.layer.cornerRadius = 7.0;
    self.appointmentNums.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _icon = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserIcon"] copy];
    _name = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"] copy];
    
    //认证状态
    NSInteger state = [[[NSUserDefaults standardUserDefaults]objectForKey:@"auditState"]integerValue];
    if (state == -1)
    {
        self.approveLabel.text = @"未认证";
    }
    else if(state == -2)
    {
        self.approveLabel.text = @"审核中";
    }
    else if(state > 0)
    {
        self.approveLabel.text = @"已认证";
    }
    else
    {
        self.approveLabel.text = @"审核未通过";
    }
    
    _icon ? nil : (_icon = @"");
    _name ? nil : (_name = @"");
    if (_icon.length > 0) {
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:_icon] placeholderImage:[UIImage imageNamed:@"list_user-big_example_pic.png"]];
    }
    else{
        [self.avatarImage setImage:[UIImage imageNamed:@"list_user-big_example_pic.png"]];
    }
    
    self.nameLabel.text = _name;
}
- (IBAction)visibleNearbyClicked:(UISwitch *)sender {
    if (!sender.on)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.dimBackground = YES;
        hud.labelText = NSLocalizedString(@"附近的人将不能搜索到您", nil);
        [hud hide:YES afterDelay:1.5];
    }
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
