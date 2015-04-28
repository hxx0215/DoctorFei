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
@property (weak, nonatomic) IBOutlet UILabel *auditTitile;
@property (weak, nonatomic) IBOutlet UILabel *auditContent;
@end

@implementation DoctorApproveViewController
{
    MBProgressHUD *hud;
    UIImage *imageUrlString;
    NSArray *titles;
    NSArray *contents;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    titles = @[@"请上传个人资质证明",@"认证中...",@"认证未通过",@"认证已通过"];
    contents = @[@"请上传您的胸牌或职业证书等资质证明，上传资料仅用于认证，患者及其他第三方不可见",@"正在帮您认证,请耐心等待",@"请确认资料或重新拍照后重新重新上传",@"恭喜您,已通过资质认证"];
    self.auditTitile.text = titles[self.auditState];
    self.auditContent.text = contents[self.auditState];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.auditImageURL]]];
    if ((self.auditState == 0) || (self.auditState == 2))
        image = nil;
    if (image){
        [self.approveImage setImage:image forState:UIControlStateNormal];
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
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)chooseApproveImage:(id)sender {
    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", nil];
    }
    [sheet showInView:self.view];
}

- (IBAction)commitButtonClicked:(id)sender {
    if (self.approveImage.currentImage)
        [self uploadImage:self.approveImage.currentImage];
}

- (void)uploadImage: (UIImage *)image {
    hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"图片上传中..."];
    [DoctorAPI uploadImage:image success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *dataDict = [responseObject firstObject];
        NSString *urlString = dataDict[@"spath"];
        //        NSString *urlString = [responseObject firstObject];
        if (urlString && urlString.length > 0) {
            [self updateAuditWithURLString:urlString];
            [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"auditImageURL"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
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
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:nil];
//    }
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
