//
//  MySelfMainTableViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import "MySelfMainTableViewController.h"
#import <MBProgressHUD.h>
#import "MemberAPI.h"
#import <UIImageView+WebCache.h>
#import "TextBasicInfoViewController.h"
#import "MySelfGenderSelectTableViewController.h"
#import "ImageUtil.h"
@interface MySelfMainTableViewController ()
    <TextBasicInfoVCDelegate, MySelfGenderSelectVCDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UISwitch *phoneOpenSwitch;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *visiableSwitch;
- (IBAction)phoneOpenSwitchValueChanged:(id)sender;
- (IBAction)visiableSwitchValueChanged:(id)sender;

@end

@implementation MySelfMainTableViewController
{
    NSString *icon,*name, *phone, *email;
    NSNumber *gender;
    NSArray *infoTitleArray, *infoPlaceHolderArray, *infoValueArray, *infoKeyboardTypeArray;
    MBProgressHUD *hud;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadInfoLabel];
    NSNumber *openMobile = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserIsOpenMobile"];
    NSNumber *visible = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserVisible"];
    if (openMobile) {
        [_phoneOpenSwitch setOn:openMobile.intValue];
    }else{
        [_phoneOpenSwitch setEnabled:NO];
    }
    if (visible) {
        [_visiableSwitch setOn:visible.intValue];
    }else{
        [_visiableSwitch setEnabled:NO];
    }
    
    [self fetchOpenInfoState];
    

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
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([segue.identifier isEqualToString:@"MySelfBasicInfoEditSegueIdentifier"]) {
        TextBasicInfoViewController *vc = [segue destinationViewController];
        [vc setTitleString:infoTitleArray[indexPath.row]];
        [vc setPlaceHolderString:infoPlaceHolderArray[indexPath.row]];
        [vc setValueString:infoValueArray[indexPath.row]];
        [vc setKeyboardType:[infoKeyboardTypeArray[indexPath.row] intValue]];
        [vc setDelegate:self];
    }else if ([segue.identifier isEqualToString:@"MySelfGenderSelectSegueIdentifier"]) {
        MySelfGenderSelectTableViewController *vc = [segue destinationViewController];
        [vc setDelegate:self];
    }
}

- (void)reloadInfoLabel {
    icon = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserIcon"];
    name = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserRealName"];
    phone = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserPhone"];
    email = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserEmail"];
    icon ? nil : (icon = @"");
    name ? nil : (name = @"");
    phone ? nil : (phone = @"");
    email ? nil : (email = @"");
    
    if (icon.length > 0) {
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
    }
    else{
        [_avatarImageView setImage:[UIImage imageNamed:@"list_user-big_example_pic"]];
    }
    
    [_nameLabel setText:name];
    [_phoneLabel setText:phone];
    [_emailLabel setText:email];
    
    gender = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserGender"];
    [_genderLabel setText:gender.intValue ? @"女" : @"男"];
    
    infoTitleArray = @[@"", @"姓名", @"", @"电话", @"", @"邮箱"];
    infoPlaceHolderArray = @[@"", @"请输入姓名", @"", @"请输入电话号码", @"", @"请输入邮箱地址"];
    infoValueArray = @[@"", name, @"", phone, @"", email];
    infoKeyboardTypeArray = @[[NSNull null], @(UIKeyboardTypeDefault), [NSNull null], @(UIKeyboardTypeNumberPad), [NSNull null], @(UIKeyboardTypeEmailAddress)];

}

- (void)fetchOpenInfoState {
    NSNumber *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSDictionary *param = @{@"uid": uid};
    [MemberAPI getOpenInfoWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = [responseObject firstObject];
        [[NSUserDefaults standardUserDefaults]setObject:result[@"isopenmobile"] forKey:@"UserIsOpenMobile"];
        [[NSUserDefaults standardUserDefaults]setObject:result[@"visible"] forKey:@"UserVisible"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result[@"isopenmobile"] intValue]) {
                [_phoneOpenSwitch setEnabled:YES];
                [_phoneOpenSwitch setOn:YES animated:YES];
            }else{
                [_phoneOpenSwitch setEnabled:YES];
                [_phoneOpenSwitch setOn:NO animated:YES];
            }
            if ([result[@"visible"]intValue]) {
                [_visiableSwitch setEnabled:YES];
                [_visiableSwitch setOn:YES animated:YES];
            }else{
                [_visiableSwitch setEnabled:YES];
                [_visiableSwitch setOn:NO animated:YES];
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}
- (void)setOpenInfoStateWithType:(NSNumber *)type state:(NSNumber *)state {
    NSNumber *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSMutableDictionary *param = [@{
                                   @"suid": uid,
                                   @"stype": type
                                   }mutableCopy];
    if (type.intValue) {
        [param setObject:state forKey:@"visible"];
    }else{
        [param setObject:state forKey:@"isopenmobile"];
    }
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [MemberAPI setOpenInfoWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = [responseObject firstObject];
        NSLog(@"%@",result);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = result[@"msg"];
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)updateMemberInfoWithKey:(NSString *)key value:(id) value {
    NSNumber *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    hud = [MBProgressHUD HUDForView:self.view.window];
    if (hud.alpha == 0) {
        hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    }
    NSDictionary *param = @{
                            @"memberid": uid,
                            key: value
                            };
    [MemberAPI updateInfomationWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = [responseObject firstObject];
        if ([result[@"state"] intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([key isEqualToString:@"headimage"]) {
                    [[NSUserDefaults standardUserDefaults]setObject:value forKey:@"UserIcon"];
                }else if ([key isEqualToString:@"realname"]) {
                    [[NSUserDefaults standardUserDefaults]setObject:value forKey:@"UserRealName"];
                }else if ([key isEqualToString:@"email"]) {
                    [[NSUserDefaults standardUserDefaults]setObject:value forKey:@"UserEmail"];
                }else if ([key isEqualToString:@"usersex"]) {
                    [[NSUserDefaults standardUserDefaults]setObject:value forKey:@"UserGender"];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self reloadInfoLabel];
            });

        }
        hud.mode = MBProgressHUDModeText;
        hud.labelText = result[@"msg"];
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
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
    [MemberAPI uploadImageWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        NSString *urlString = dataDict[@"spath"];
        //        NSString *urlString = [responseObject firstObject];
        if (urlString && urlString.length > 0) {
            [self updateMemberInfoWithKey:@"headimage" value:urlString];
//            [self updateInfoWithURLString:urlString];
        }
        else{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"图片上传失败";
            [hud hide:YES afterDelay:1.0f];
            //            hud.detailsLabelText = dataDict[@"error"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}


#pragma mark - UIActionSheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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
#pragma mark - UIImagePckerController Delegate
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


#pragma mark - UI Actions
- (IBAction)phoneOpenSwitchValueChanged:(id)sender {
    [self setOpenInfoStateWithType:@(0) state:@(_phoneOpenSwitch.isOn)];
}

- (IBAction)visiableSwitchValueChanged:(id)sender {
    [self setOpenInfoStateWithType:@(1) state:@(_visiableSwitch.isOn)];
}

#pragma mark - TextBasicInfoVC Delegate

- (void)textBasicInfoVC:(TextBasicInfoViewController *)infoVC didClickedConfirmButtonWithText:(NSString *)text {
    if ([infoVC.titleString isEqualToString:@"姓名"]) {
        [self updateMemberInfoWithKey:@"realname" value:text];
    }else if ([infoVC.titleString isEqualToString:@"电话"]) {
        //接口未提供该字段
    }else if ([infoVC.titleString isEqualToString:@"邮箱"]) {
        [self updateMemberInfoWithKey:@"email" value:text];
    }
}

#pragma mark - MySelfGenderSelectVC Delegate

- (void)genderSelectVC:(MySelfGenderSelectTableViewController *)genderSelectVC selectGender:(NSNumber *)selectGender {
    [self updateMemberInfoWithKey:@"usersex" value:selectGender];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self uploadIcon];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row != 0 && indexPath.row != 2) {
        [self performSegueWithIdentifier:@"MySelfBasicInfoEditSegueIdentifier" sender:nil];
    }
}
@end
