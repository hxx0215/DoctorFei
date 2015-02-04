//
//  AgendaArrangementDetailEventViewController.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/5.
//
//

#import <UIKit/UIKit.h>
@class AgendaArrangementDetailEventViewController;

@protocol AgendaArrangementDetailEventVCDelegate <NSObject>

- (void)confirmButtonClickedForAgendaArrangementDetailEventVC:(AgendaArrangementDetailEventViewController *)vc eventString:(NSString *)eventString;

@end

@interface AgendaArrangementDetailEventViewController : UIViewController

@property (nonatomic, weak) id<AgendaArrangementDetailEventVCDelegate> delegate;

@end
