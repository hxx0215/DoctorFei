//
//  AgendaTimaScheduleViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/13.
//
//

#import "AgendaTimeScheduleViewController.h"
#import "DoctorAPI.h"
#import <MBProgressHUD.h>
@interface AgendaTimeScheduleViewController()
@property (weak, nonatomic) IBOutlet UIImageView *scheduleTableBackImage;
@property (nonatomic, copy) NSDictionary *scheduleMap;
@property (nonatomic, copy) NSArray *scheduleDay;
@end
@implementation AgendaTimeScheduleViewController
{
    MBProgressHUD *hud;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.scheduleTableBackImage.layer.cornerRadius = 5.0;
    self.scheduleTableBackImage.layer.masksToBounds = YES;
    self.scheduleMap = @{@"Monday_AM": @11,
                         @"Monday_PM": @12,
                         @"Tuesday_AM": @13,
                         @"Tuesday_PM": @14,
                         @"Wednesday_AM":@15,
                         @"Wednesday_PM":@16,
                         @"Thursday_AM":@17,
                         @"Thursday_PM":@18,
                         @"Friday_AM":@19,
                         @"Friday_PM":@20,
                         @"Saturday_AM":@21,
                         @"Saturday_PM":@22,
                         @"Sunday_AM":@23,
                         @"Sunday_PM":@24};
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self updateSchedule];
    [self loadSchedule];
}
-(void)loadSchedule
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId
                             };
    [DoctorAPI getDoctorScheduleWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        for (id str in [[responseObject firstObject] allKeys]){
            NSNumber *tag = nil;
            if ((tag =[self.scheduleMap objectForKey:str])){
                UIButton *btn = (UIButton *)[self.view viewWithTag:[tag integerValue]];
                btn.selected = [responseObject[0][str] integerValue] == 1;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)updateSchedule
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"Monday_AM": [self scheduleDataWithKey:@"Monday_AM"],
                             @"Monday_PM": [self scheduleDataWithKey:@"Monday_PM"],
                             @"Tuesday_AM": [self scheduleDataWithKey:@"Tuesday_AM"],
                             @"Tuesday_PM": [self scheduleDataWithKey:@"Tuesday_PM"],
                             @"Wednesday_AM": [self scheduleDataWithKey:@"Wednesday_AM"],
                             @"Wednesday_PM": [self scheduleDataWithKey:@"Wednesday_PM"],
                             @"Thursday_AM": [self scheduleDataWithKey:@"Thursday_AM"],
                             @"Thursday_PM": [self scheduleDataWithKey:@"Thursday_PM"],
                             @"Friday_AM": [self scheduleDataWithKey:@"Friday_AM"],
                             @"Friday_PM": [self scheduleDataWithKey:@"Friday_PM"],
                             @"Saturday_AM": [self scheduleDataWithKey:@"Saturday_AM"],
                             @"Saturday_PM": [self scheduleDataWithKey:@"Saturday_PM"],
                             @"Sunday_AM": [self scheduleDataWithKey:@"Sunday_AM"],
                             @"Sunday_PM": [self scheduleDataWithKey:@"Sunday_PM"]
                             };
    [DoctorAPI updateDoctorScheduleWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success_pic.png"]];
        if([dic[@"state"] integerValue] == 1)
        {
            hud.customView = imageView;
        }
        else
        {
        }
        NSLog(@"%@",dic[@"msg"]);
        hud.dimBackground = YES;
        hud.labelText = dic[@"msg"];
        [hud hide:YES afterDelay:2.0];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}
-(IBAction)scheduleSelected:(UIButton *)sender{
    sender.selected = !sender.selected;
}
- (IBAction)confirm:(UIBarButtonItem *)sender {
    [self updateSchedule];
}
- (NSNumber *)scheduleDataWithKey:(NSString *)str{
    NSNumber *tag = self.scheduleMap[str];
    if (!tag)
        return @0;
    UIButton *btn = (UIButton *)[self.view viewWithTag:[tag integerValue]];
    if (btn.selected)
        return @1;
    else
        return @0;
}
@end
