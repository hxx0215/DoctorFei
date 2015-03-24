//
//  ContactGroupChatListViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import "ContactGroupChatListViewController.h"
#import "ContactMainViewController.h"

@interface ContactGroupChatListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *groupData;
@end

@implementation ContactGroupChatListViewController
static NSString * const contactGroupChatListIdentifier = @"ContactGroupChatListIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    self.groupData = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getGroupData];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getGroupData{
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupData.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactGroupChatListIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactGroupChatListIdentifier];
    }
    cell.textLabel.textColor = [UIColor greenColor];
    cell.textLabel.text = @"新建群";
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        [self performSegueWithIdentifier:@"ContactCreateGroupSequeIdentifier" sender:indexPath];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ContactCreateGroupSequeIdentifier"]){
        ContactMainViewController *vc = [segue destinationViewController];
        vc.contactMode = ContactMainViewControllerModeCreateGroup;
        // TODO:会诊
        vc.didSelectFriend = ^(NSArray *friends){
            NSLog(@"%@",friends);
        };
    }
}


@end
