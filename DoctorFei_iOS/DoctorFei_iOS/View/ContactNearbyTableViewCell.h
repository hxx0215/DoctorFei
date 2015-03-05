//
//  ContactNearbyTableViewCell.h
//  DoctorFei_iOS
//
//  Created by hxx on 1/13/15.
//
//

#import <UIKit/UIKit.h>

@interface ContactNearbyTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *iconImage;
@property (nonatomic,weak) IBOutlet UIButton *addButton;
@property (nonatomic,weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic,weak) IBOutlet UIImageView *typeImage;
-(void)setDataDic:(NSMutableDictionary *)dic;
@end
