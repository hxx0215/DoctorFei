//
//  ContactTransferViewController.h
//  DoctorFei_iOS
//
//  Created by hxx on 1/27/15.
//
//

#import <UIKit/UIKit.h>
#import "Friends.h"

@interface ContactTransferViewController : UIViewController
@property (nonatomic, copy)NSNumber *patientID;
@property (nonatomic, copy)NSNumber *targetID;
@property (nonatomic, strong)Friends *target;
@end
