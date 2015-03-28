//
//  OrganDisplayViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/27.
//
//
typedef enum OrganType{
    OrganTypeShow,
    OrganTypeOutstanding,
    OrganTypeNursing
}OrganType;
#import <UIKit/UIKit.h>

@interface OrganDisplayViewController : UIViewController
@property (nonatomic, assign) OrganType type;
@end
