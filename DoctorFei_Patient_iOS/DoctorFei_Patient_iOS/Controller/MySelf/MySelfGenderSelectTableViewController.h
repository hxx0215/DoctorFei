//
//  MySelfGenderSelectTableViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/5.
//
//

#import <UIKit/UIKit.h>

@class MySelfGenderSelectTableViewController;

@protocol MySelfGenderSelectVCDelegate <NSObject>

- (void)genderSelectVC:(MySelfGenderSelectTableViewController *)genderSelectVC selectGender:(NSNumber *)selectGender;

@end

@interface MySelfGenderSelectTableViewController : UITableViewController

@property (nonatomic, weak) id<MySelfGenderSelectVCDelegate> delegate;

@end
