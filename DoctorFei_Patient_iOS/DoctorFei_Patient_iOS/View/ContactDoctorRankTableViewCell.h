//
//  ContactDoctorRankTableViewCell.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/12.
//
//

#import <UIKit/UIKit.h>

@interface ContactDoctorRankTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *dataDict;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@end
