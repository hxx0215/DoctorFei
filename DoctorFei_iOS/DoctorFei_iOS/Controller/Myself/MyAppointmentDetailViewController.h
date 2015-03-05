//
//  MyAppointmentDetailViewController.h
//  DoctorFei_iOS
//
//  Created by hxx on 1/6/15.
//
//

#import <UIKit/UIKit.h>
typedef enum AppointDetailType{
    AppointDetailTypeNoButton = 0,
    AppointDetailTypeAgreeAndDisagree,
    AppointDetailTypeAgreeAndAdd,
    AppointDetailTypeAgreed,
    AppointDetailTypeDisagreed
}AppointDetailType;
@interface MyAppointmentDetailViewController : UIViewController
@property (nonatomic, copy)NSString *date;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, assign)AppointDetailType flag;
@property (nonatomic, assign)NSNumber *ID;//转诊或预约编号
@end
