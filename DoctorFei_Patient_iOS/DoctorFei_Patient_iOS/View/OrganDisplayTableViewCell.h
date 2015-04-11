//
//  OrganDisplayTableViewCell.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/2/27.
//
//

#import <UIKit/UIKit.h>
#import "OrganDisplayViewController.h"

@interface OrganDisplayTableViewCell : UITableViewCell
- (void)setCellData:(NSDictionary *)data withType:(OrganType)type;
@end
