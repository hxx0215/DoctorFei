//
//  DoctorApproveViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/5/15.
//
//

#import "DoctorApproveViewController.h"
#import "ImageUtil.h"
@interface DoctorApproveViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *approveImage;

@end

@implementation DoctorApproveViewController

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
