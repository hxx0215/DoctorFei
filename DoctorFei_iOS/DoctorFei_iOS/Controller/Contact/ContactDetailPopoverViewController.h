//
//  ContactDetailPopoverViewController.h
//  DoctorFei_iOS
//
//  Created by hxx on 1/20/15.
//
//

#import <UIKit/UIKit.h>

@interface ContactDetailPopoverViewController : UIViewController
@property (nonatomic, copy) void (^showRecord)();
@property (nonatomic, copy) void (^launchConsultation)();
@property (nonatomic, copy) void (^transfer)();
@property (nonatomic, copy) void (^sendOutpatientTime)();
@end
