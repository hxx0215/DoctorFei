//
//  ContactGroupUserCollectionViewCell.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/24.
//
//

#import <UIKit/UIKit.h>

@interface ContactGroupUserCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
