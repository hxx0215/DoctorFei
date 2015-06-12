//
//  ContactNewFriendGroupTableViewCell.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/6/13.
//
//

#import <UIKit/UIKit.h>

@interface ContactNewFriendGroupTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreeLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
- (IBAction)agreeButtonClicked:(id)sender;
@property (nonatomic, strong) NSDictionary *dict;
@end
