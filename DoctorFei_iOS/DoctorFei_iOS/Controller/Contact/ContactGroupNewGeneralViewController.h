//
//  ContactGroupNewGeneralViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/4.
//
//

typedef NS_ENUM(NSUInteger, ContactGroupNewMode) {
    ContactGroupNewModeSameCity,
    ContactGroupNewModePrivate
};

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
@interface ContactGroupNewGeneralViewController : UITableViewController
@property (nonatomic, assign) ContactGroupNewMode vcMode;
@property (nonatomic, strong) BMKPoiInfo *currentPoi;

@end
