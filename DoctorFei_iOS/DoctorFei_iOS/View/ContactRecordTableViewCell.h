//
//  ContactRecordTableViewCell.h
//  DoctorFei_iOS
//
//  Created by hxx on 2/27/15.
//
//

#import <UIKit/UIKit.h>

@interface ContactRecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic, copy) NSArray *imageUrl;
@property (weak, nonatomic) IBOutlet UILabel *recordDate;
@end
