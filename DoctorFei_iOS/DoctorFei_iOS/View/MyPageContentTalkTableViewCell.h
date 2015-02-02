//
//  MyPageContentTalkTableViewCell.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/1/18.
//
//

#import <UIKit/UIKit.h>
@class ShuoShuo;
@interface MyPageContentTalkTableViewCell : UITableViewCell
@property (nonatomic, strong) ShuoShuo *shuoshuo;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
