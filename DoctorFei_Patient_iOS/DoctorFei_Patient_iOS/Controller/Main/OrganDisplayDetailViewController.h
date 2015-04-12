//
//  OrganDisplayDetailViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/27.
//
//

#import <UIKit/UIKit.h>
#import "OrganDisplayViewController.h"

@interface OrganDisplayDetailViewController : UIViewController
@property (nonatomic, copy)NSString *ID;
@property (nonatomic, assign)OrganType type;
@end
