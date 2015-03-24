//
//  ContactGroupDetailUserTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/24.
//
//

#import "ContactGroupDetailUserTableViewController.h"
#import "ContactGroupUserCollectionViewCell.h"
#import "Chat.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
static NSString *ContactGroupUserCellIdentifier = @"ContactGroupUserCellIdentifier";
@interface ContactGroupDetailUserTableViewController ()
    <UICollectionViewDelegate, UICollectionViewDataSource>
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ContactGroupDetailUserTableViewController
{
    NSArray *userArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    [self.tableView setTableFooterView:[UIView new]];
    CGRect headRect = self.tableView.tableHeaderView.frame;
    headRect.size.height = 110.0f;
    [self.tableView.tableHeaderView setFrame:headRect];
    [self reloadCollectionViewData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadCollectionViewData{
    userArray = _currentChat.user.allObjects;
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
    } completion:^(BOOL finished) {
        if (finished) {
//            NSInteger totalItems = [self.collectionView numberOfItemsInSection:0];
//            NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:totalItems - 1 inSection:0];
//            UICollectionViewLayoutAttributes *attributes =
//            [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:lastIndex];
//            NSLog(@"%@",NSStringFromCGRect(attributes.frame));
//            CGRect headRect = self.tableView.tableHeaderView.frame;
//            headRect.size.height = attributes.frame.origin.y + attributes.frame.size.height + 10;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView.tableHeaderView setFrame:headRect];
//            });
        }
    }];
}

#pragma mark - Actions
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return userArray.count + 3;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ContactGroupUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ContactGroupUserCellIdentifier forIndexPath:indexPath];
    if (indexPath.item > 0 && indexPath.item < userArray.count + 1) {
        Friends *friend = userArray[indexPath.item];
        [cell.nameLabel setText:friend.realname];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.icon]    placeholderImage:[UIImage imageNamed:@"details_uers_example_pic"]];
    }else if (indexPath.item == 0) {
        NSString *name = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"];
        NSString *icon = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserIcon"];
        [cell.nameLabel setText:name];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"details_uers_example_pic"]];
    }else if (indexPath.item == userArray.count + 1){
        [cell.nameLabel setText:@""];
        [cell.imageView setImage:[UIImage imageNamed:@"add_user_btn"]];
    }else if (indexPath.item == userArray.count + 2){
        [cell.nameLabel setText:@""];
        [cell.imageView setImage:[UIImage imageNamed:@"minus-user_btn"]];
    }
    [cell.deleteButton setHidden:YES];
    return cell;
}

#pragma mark - UICollectionView Delegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
