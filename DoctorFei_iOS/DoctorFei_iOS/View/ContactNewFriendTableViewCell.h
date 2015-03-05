//
//  ContactNewFriendTableViewCell.h
//  DoctorFei_iOS
//
//  Created by hxx on 1/12/15.
//
//

#import <UIKit/UIKit.h>

@interface ContactNewFriendTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *iconImage;
@property (nonatomic,weak) IBOutlet UIButton *addButton;
-(void)setDataDic:(NSMutableDictionary *)dic;
@end
