//
//  ContactGroupNearbyTableViewCell.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/3.
//
//

#import <UIKit/UIKit.h>

@interface ContactGroupNearbyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@end
