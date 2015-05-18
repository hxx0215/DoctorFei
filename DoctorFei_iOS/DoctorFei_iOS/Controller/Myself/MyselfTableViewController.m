//
//  MyselfTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#define kMyselfInfoNameArray @[@"头像", @"姓名", @"医院", @"科室", @"职称", @"邮箱"]
#define kMyselfInfoKeyArray @[@"headimage", @"realname", @"hospital", @"department", @"jobtitle", @"email"]
#import "MyselfTableViewController.h"
#import "MySelfBasicInfoEditTableViewController.h"
#import "MyselfIntroInfoEditTableViewController.h"
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
#import <UIImageView+WebCache.h>
#import "ImageUtil.h"
#import "NSString+Crypt.h"

@interface MyselfTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmengLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextView *introductionTextView;
//@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;


@end

@implementation MyselfTableViewController
{
    NSArray *basicInfoArray;
    NSString *icon, *name, *hospital, *department, *jobTitle, *email, *introduction;
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
//    [self.introductionTextView setTextContainerInset:UIEdgeInsetsZero];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    icon = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserIcon"] copy];
    name = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"] copy];
    hospital = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserHospital"] copy];
    department = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserDepartment"] copy];
    jobTitle = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserJobTitle"] copy];
    email = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserEmail"] copy];
    introduction = [[[NSUserDefaults standardUserDefaults]objectForKey:@"UserOtherContact"]copy];
    
    icon ? nil : (icon = @"");
    name ? nil : (name = @"");
    hospital ? nil : (hospital = @"");
    department ? nil : (department = @"");
    jobTitle ? nil : (jobTitle = @"");
    email ? nil : (email = @"");
    introduction ? nil : (introduction = @"");
    basicInfoArray = @[icon, name, hospital, department, jobTitle, email];
    
    if (icon.length > 0) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
    }
    else{
        [self.avatarImageView setImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
    }
    [self.nameLabel setText:name];
    [self.hospitalNameLabel setText:hospital];
    [self.departmengLabel setText:department];
    [self.jobTitleLabel setText:jobTitle];
    [self.emailLabel setText:email];
    [self.introductionTextView setText:introduction];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - updateHeadimage

- (void)updateInfoWithURLString: (NSString *)urlString {
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
//    hud.dimBackground = YES;
    [hud setLabelText:@"修改申请中..."];
    NSNumber *currentUserId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
//    NSString *currentInfo = @"";
    NSDictionary *params = @{
                             @"doctorid": currentUserId,
                             @"headimage": urlString
                             };
    [DoctorAPI updateInfomationWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"修改成功";
            [[NSUserDefaults standardUserDefaults]setObject:urlString forKey:@"UserIcon"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
//            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            hud.labelText = @"修改错误";
            hud.detailsLabelText = dataDict[@"msg"];
        }
        [hud hide:YES afterDelay:1.5f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)uploadImage: (UIImage *)image {
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"图片上传中..."];

    NSString *str = [UIImageJPEGRepresentation(image, 0.8) base64EncodedStringWithOptions:0];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"|JH|"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"|KG|"];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"|HC|"];

    NSDictionary *params = @{
                             @"picturename": [NSString stringWithFormat:@"%d.jpg", (int)[[NSDate date] timeIntervalSince1970]],
                             @"img": str
                             };

    [DoctorAPI uploadImageWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        NSString *urlString = dataDict[@"spath"];
//        NSString *urlString = [responseObject firstObject];
        if (urlString && urlString.length > 0) {
            [self updateInfoWithURLString:urlString];
        }
        else{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"图片上传失败";
//            hud.detailsLabelText = dataDict[@"error"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)uploadIcon{
    
    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", nil];
    }
    sheet.tag = 255;
//    [sheet showInView:self.view];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = 0;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                default:
                    return;
            }
        }
        else {
            if (buttonIndex == 1) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
        }
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        if(image)
        {
            UIImage *cropImage = [ImageUtil imageWithImage:image scaledToSize:CGSizeMake(72.0f, 72.0f)];
//            [self updateInfo];
            [self uploadImage:cropImage];
        }
    }];
    
    //MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:((UIViewController*)self.delegate).view animated:YES];
    //hud.labelText = NSLocalizedString(@"正在上传", nil);
}

#pragma mark - Navigation
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([segue.identifier isEqualToString:@"MyselfBasicInfoEditSegueIdentifier"]) {
        MySelfBasicInfoEditTableViewController *vc = [segue destinationViewController];
        [vc setName:kMyselfInfoNameArray[indexPath.row]];
        [vc setKey:kMyselfInfoKeyArray[indexPath.row]];
        [vc setValue:basicInfoArray[indexPath.row]];
    }
    else if ([segue.identifier isEqualToString:@"MyselfIntroInfoEditSegueIdentifier"]) {
        MyselfIntroInfoEditTableViewController *vc = [segue destinationViewController];
        [vc setIntroValue:introduction];
    }
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self uploadIcon];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row != 0) {
        [self performSegueWithIdentifier:@"MyselfBasicInfoEditSegueIdentifier" sender:nil];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"MyselfIntroInfoEditSegueIdentifier" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}
@end
