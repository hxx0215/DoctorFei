//
//  swiftActionSheet.h
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/12/15.
//
//

//这个类只是用来解决iOS7下使用swift创建ActionSheet显示不正确的。其他情况请不要使用
#import <UIKit/UIKit.h>

@interface swiftActionSheet : NSObject
-(void)show;
@property (nonatomic, weak)UIView *father;
@property (nonatomic, assign)id delegate;
@end
