//
//  DoctorApproveViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/5/15.
//
//

#import "DoctorApproveViewController.h"
#import "DoctorAPI.h"
#import "ImageUtil.h"
#import <MBProgressHUD.h>

@interface DoctorApproveViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *approveImage;
@property (nonatomic ,strong) UIImage *auditImage;
@end

@implementation DoctorApproveViewController
{
    MBProgressHUD *hud;
    UIImage *imageUrlString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)chooseApproveImage:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil),NSLocalizedString(@"从手机相册选择", nil), nil];
    [actionSheet showInView:self.view];
}

- (IBAction)commitButtonClicked:(id)sender {
    [self uploadImage:self.approveImage.currentImage];
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
            [self updateAuditWithURLString:urlString];
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

-(void)updateAuditWithURLString:(NSString *)urlString
{
    [hud setLabelText:@"提交申请中..."];
    NSNumber *currentUserId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    //    NSString *currentInfo = @"";
    NSDictionary *params = @{
                             @"doctorid": currentUserId,
                             @"img": urlString
                             };
    [DoctorAPI setAuditWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = @"修改成功";
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

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSUInteger sourceType = 0;
    if (0==buttonIndex){
        //拍照
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (1==buttonIndex){
        //相册
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else{
        return ;
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *cropImage = [ImageUtil imageWithImage:image scaledToSize:CGSizeMake(160.0f, 160.0f)];
        [self.approveImage setImage:cropImage forState:UIControlStateNormal];
    }];
}
@end
