//
//  ContactNewFriendGroupTableViewCell.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/6/12.
//
//

#import <UIKit/UIKit.h>

@interface ContactNewFriendGroupTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
- (IBAction)acceptButtonClicked:(id)sender;

@property (nonatomic, strong) NSDictionary *dict;
@end
