//
//  ContactGroupNewGeneralViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/4.
//
//

#import "ContactGroupNewGeneralViewController.h"
#import "ImageUtil.h"
#import <MBProgressHUD.h>
#import "DoctorAPI.h"
#import "UIImageView+WebCache.h"
#import <ReactiveCocoa.h>
#import "ChatAPI.h"
#import "GroupChat.h"
@interface ContactGroupNewGeneralViewController ()
    <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)commitButtonClicked:(id)sender;
@end

@implementation ContactGroupNewGeneralViewController
{
    NSString *currentIcon;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    RAC(self.commitButton, enabled) = [RACSignal combineLatest:@[_nameTextField.rac_textSignal, _introTextView.rac_textSignal] reduce:^(NSString *name, NSString *intro){
        if (_vcMode == ContactGroupNewModePrivate) {
            return @(name.length > 1 && name.length < 11);
        }
        return @(name.length > 1 && name.length < 11 && intro.length > 14);
    }];
    if (_vcMode == ContactGroupNewModePrivate) {
        [_commitButton setTitle:@"保存并提交" forState:UIControlStateNormal];
    }
    if (_currentGroup != nil) {
        self.title = @"群信息";
        self.nameTextField.text = _currentGroup.name;
        self.introTextView.text = _currentGroup.note;
        self.introTextView.textColor = [UIColor blackColor];
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_currentGroup.icon] placeholderImage:[UIImage imageNamed:@"group_preinstall_pic"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"请输入群简介(不少于15个字)"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"请输入群简介(不少于15个字)";
        textView.textColor = UIColorFromRGB(0xCACACA); //optional
    }
    [textView resignFirstResponder];
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_vcMode == ContactGroupNewModePrivate && indexPath.row == 2) {
        return 0;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //上传图片
        [self uploadIcon];
    }
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)commitButtonClicked:(id)sender {
    if (_currentGroup != nil) {
        NSDictionary *param = @{
                                @"groupid": _currentGroup.groupId,
                                @"name": _nameTextField.text,
                                @"note": _introTextView.text,
                                @"icon": currentIcon.length > 0 ? currentIcon : _currentGroup.icon
                                };
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.labelText = @"提交中...";

        [ChatAPI updateChatGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
            NSDictionary *result = [responseObject firstObject];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = result[@"msg"];
            [hud hide:YES afterDelay:1.0f];
            if ([result[@"state"] intValue] == 1){
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.5f];
        }];
    }else{
        NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:userId forKey:@"userid"];
        [param setObject:@2 forKey:@"usertype"];
        if (_vcMode == ContactGroupNewModePrivate) {
            [param setObject:@1 forKey:@"flag"];
        }else{
            [param setObject:@0 forKey:@"flag"];
            [param setObject:_currentPoi.city forKey:@"city"];
            [param setObject:_currentPoi.address forKey:@"address"];
            [param setObject:@(_currentPoi.pt.longitude) forKey:@"lng"];
            [param setObject:@(_currentPoi.pt.latitude) forKey:@"lat"];
        }
        [param setObject:_introTextView.text forKey:@"note"];
        [param setObject:_nameTextField.text forKey:@"name"];
        if (currentIcon.length > 0) {
            [param setObject:currentIcon forKey:@"icon"];
        }
        [param setObject:@1 forKey:@"visible"];
        NSLog(@"%@",param);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.labelText = @"提交中...";
        [ChatAPI setChatGroupWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
            NSDictionary *result = [responseObject firstObject];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = result[@"msg"];
            if ([result[@"state"] intValue] == 1){
                //Success
                [self performSegueWithIdentifier:@"ContactCreateGroupSuccessBackSegueIdentifier" sender:nil];
            }
            [hud hide:YES afterDelay:1.0f];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error.localizedDescription);
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = error.localizedDescription;
            [hud hide:YES afterDelay:1.5f];
        }];
    }
}

- (void)uploadImage: (UIImage *)image {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
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
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"图片上传成功";
            currentIcon = urlString;
            [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"group_preinstall_pic"]];
        }
        else{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"图片上传失败";
            //            hud.detailsLabelText = dataDict[@"error"];
        }
        [hud hide:YES afterDelay:1.0f];
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

@end
