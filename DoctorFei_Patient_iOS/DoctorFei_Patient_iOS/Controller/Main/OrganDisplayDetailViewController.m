//
//  OrganDisplayDetailViewController.m
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/27.
//
//

#import "OrganDisplayDetailViewController.h"
#import "MemberAPI.h"
#import "ShareUtil.h"
#import "MBProgressHUD.h"
typedef void (^shareHide)(void);
@interface OrganShareView :UIView
@property (nonatomic,copy)shareHide hide;
@end
@implementation OrganShareView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.hide();
}
@end
@interface OrganDisplayDetailViewController ()
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet OrganShareView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareBottomConstraint;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation OrganDisplayDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.shareView.hidden = YES;
    typeof(self) __weak weakSelf = self;
    self.shareView.hide = ^{
       typeof(self) strongSelf = weakSelf;
        [strongSelf showShare:NO];
    };
    self.shareBottomConstraint.constant = -240;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.content.text = @"";
    NSDictionary *params = @{@"id": self.ID};
    switch (self.type){
        case OrganTypeShow:{
            [MemberAPI getOrgListWithParameters:params success:^(AFHTTPRequestOperation *operation,id responseObject){
                self.content.text = [[responseObject firstObject] objectForKey:@"des"];
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
            }];
            break;
        }
        case OrganTypeNursing:{
            [MemberAPI getNursingWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
                self.content.text = [[responseObject firstObject] objectForKey:@"des"];
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
            }];
            break;
        }
        case OrganTypeOutstanding:{
            [MemberAPI getOutStandingSampleWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
                self.content.text = [[responseObject firstObject] objectForKey:@"des"];
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
            }];
            break;
        }
        default:
            break;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)showShare:(BOOL)flag{
    if (flag){
        self.shareBottomConstraint.constant = 0;
        self.shareView.hidden = NO;
    }
    else
        self.shareBottomConstraint.constant = -240;
    [self.shareView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.shareView layoutIfNeeded];
    }completion:^(BOOL finished){
        self.shareView.hidden = !flag;
    }];
}
- (IBAction)showShareView:(id)sender {
    [self showShare:YES];
}
- (IBAction)shareAction:(UIButton *)sender {
    NSDictionary *dic = @{@"content": self.content.text,
                          @"vc" : self,
                          @"title" : @" ",
                          @"url" : @""};
    
    ShareType sharetype = ShareTypeSinaWeibo;
    switch (sender.tag) {
        case 300:
        {
            sharetype = ShareTypeSinaWeibo;
        }
            break;
         case 301:
            sharetype = ShareTypeTencentWeibo;
            break;
        case 302:
            sharetype = ShareTypeWeixiSession;
            break;
        case 303:
            sharetype = ShareTypeQQSpace;
            break;
        case 304:
            sharetype = ShareTypeQQ;
            break;
        case 305:
            sharetype = ShareTypeWeixiTimeline;
            break;
        case 306:
            sharetype = ShareTypeSMS;
            break;
        default:
            sharetype = ShareTypeSinaWeibo;
            break;
    }
    [[ShareUtil sharedShareUtil] shareTo:sharetype content:dic complete:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo>error, BOOL end){
        if (type == ShareTypeSMS)
            return ;
        switch (state) {
            case SSResponseStateBegan:
                self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.hud.labelText = @"发布中";
                break;
            case SSResponseStateSuccess:
                self.hud.mode = MBProgressHUDModeText;
                self.hud.labelText = @"发布成功";
                [self.hud hide:YES afterDelay:0.5];
                break;
            case SSResponseStateFail:
                self.hud.mode = MBProgressHUDModeText;
                self.hud.labelText = [NSString stringWithFormat:@"发布失败:%@",error];
                [self.hud hide:YES afterDelay:1.5];
            case SSResponseStateCancel:
                self.hud.labelText = @"已取消";
                [self.hud  hide:YES];
            default:
                break;
        }
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
