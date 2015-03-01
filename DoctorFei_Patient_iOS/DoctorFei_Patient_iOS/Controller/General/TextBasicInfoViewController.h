//
//  TextBasicInfoViewController.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/1.
//
//

#import <UIKit/UIKit.h>

@class TextBasicInfoViewController;

@protocol TextBasicInfoVCDelegate <NSObject>

- (void)textBasicInfoVC:(TextBasicInfoViewController *)infoVC didClickedConfirmButtonWithText:(NSString *)text;

@end

@interface TextBasicInfoViewController : UIViewController

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *placeHolderString;
@property (nonatomic, copy) NSString *valueString;
@property (nonatomic, assign) NSInteger keyboardType;
@property (nonatomic, assign) id<TextBasicInfoVCDelegate> delegate;

@end
