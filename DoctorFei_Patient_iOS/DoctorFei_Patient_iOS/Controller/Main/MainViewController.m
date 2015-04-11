//
//  MainViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/26.
//
//

#import "MainViewController.h"
#import <UIScrollView+EmptyDataSet.h>
#import "MainChatTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "Chat.h"
#import "SocketConnection.h"
#import "ContactDetailViewController.h"
#import "BaseHTTPRequestOperationManager.h"
#import "OrganDisplayViewController.h"

@interface MainViewController ()
    <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@end

@implementation MainViewController
{
    UIBarButtonItem *fetchButtonItem, *loadingButtonItem;
    CABasicAnimation *rotation;
    NSArray *chatArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    [self.tableView setTableFooterView:[UIView new]];
    fetchButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStyleDone target:self action:@selector(refreshButtonClicked:)];
    fetchButtonItem.tintColor = [UIColor whiteColor];
    loadingButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_after"]]];
    
    
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 0.7f; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableViewData) name:@"NewChatArrivedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchChatComplete) name:@"FetchChatCompleteNotification" object:nil];
    [self.navigationItem setLeftBarButtonItem:fetchButtonItem animated:YES];
    
    NSString *icon = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserIcon"];
    if (icon && icon.length > 0) {
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"home_user_example_pic"]];
    }
    else {
        [_avatarImageView setImage:[UIImage imageNamed:@"home_user_example_pic"]];
    }
    [_nameLabel setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"]];
    [_genderLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserGender"] intValue] ? @"女" : @"男"];

    
    [self reloadTableViewData];
    [[BaseHTTPRequestOperationManager sharedManager] defaultAuth];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"MainChatDetailSegueIdentifier"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        ContactDetailViewController *vc = [segue destinationViewController];
        Chat *chat = chatArray[indexPath.row];
//        [vc setCurrentFriend:chat.user];
        [vc setCurrentChat:chat];
    }
    if ([segue.identifier isEqualToString:@"ShowProjectInfoSegueIdentifier"]){
        OrganDisplayViewController *vc = [segue destinationViewController];
        vc.type = OrganTypeOutstanding;
    }
    if ([segue.identifier isEqualToString:@"ShowNursingSegueIdentifier"]){
        OrganDisplayViewController *vc = [segue destinationViewController];
        vc.type = OrganTypeNursing;
    }
}

#pragma mark - Actions
- (void)reloadTableViewData {
//    chatArray = [Chat MR_findAll];
    chatArray = [Chat MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"messages.@count > 0"]];
    [self.tableView reloadData];
}

- (void)fetchChatComplete {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [loadingButtonItem.customView.layer removeAllAnimations];
        [self.navigationItem setLeftBarButtonItem:fetchButtonItem animated:YES];
    });
}

- (IBAction)refreshButtonClicked:(id)sender {
    [self.navigationItem setLeftBarButtonItem:loadingButtonItem animated:YES];
    [loadingButtonItem.customView.layer removeAllAnimations];
    [loadingButtonItem.customView.layer addAnimation:rotation forKey:@"Spin"];
    [[SocketConnection sharedConnection]sendCheckMessages];
}


#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}
#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return chatArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MainChatCellIdentifier = @"MainChatCellIdentifier";
    MainChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainChatCellIdentifier forIndexPath:indexPath];
    [cell setCurrentChat:chatArray[indexPath.row]];
    return cell;
}

#pragma mark - DZNEmptyDatasource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc]initWithString:@"暂无历史会话记录"];
}

@end
