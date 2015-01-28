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

@implementation AgendaTimeScheduleViewController
{
    MBProgressHUD *hud;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateSchedule];
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)updateSchedule
{
    NSNumber *doctorId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"doctorid": doctorId,
                             @"Monday_AM": @1,
                             @"Monday_PM": @1,
                             @"Tuesday_AM": @1,
                             @"Tuesday_PM": @1,
                             @"Wednesday_AM": @1,
                             @"Wednesday_PM": @1,
                             @"Thursday_AM": @1,
                             @"Thursday_PM": @1,
                             @"Friday_AM": @1,
                             @"Friday_PM": @1,
                             @"Saturday_AM": @1,
                             @"Saturday_PM": @1,
                             @"Sunday_AM": @1,
                             @"Sunday_PM": @1
                             };
    [DoctorAPI updateDoctorScheduleWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dic = [responseObject firstObject];
        if([dic[@"state"] integerValue] == 1)
        {
        }
        else
        {
        }
        NSLog(@"%@",dic[@"msg"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}
@end
