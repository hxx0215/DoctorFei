//
//  ContactDetailPopoverViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/28.
//
//

#import <UIKit/UIKit.h>
#import "ContactDetailViewController.h"

@interface ContactDetailPopoverViewController : UIViewController
@property (nonatomic, assign)SEL showHisPage;
@property (nonatomic, assign)SEL departTime;
@property (nonatomic, assign)SEL launchAppointment;
@property (nonatomic, weak)ContactDetailViewController *target;
@end
