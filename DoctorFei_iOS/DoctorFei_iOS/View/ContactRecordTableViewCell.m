//
//  ContactRecordTableViewCell.m
//  DoctorFei_iOS
//
//  Created by hxx on 2/27/15.
//
//

#import "ContactRecordTableViewCell.h"
#import <UIImageView+WebCache.h>
@interface ContactRecordTableViewCell()


@property (weak, nonatomic) IBOutlet UIView *imageViews;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@end
@implementation ContactRecordTableViewCell
@synthesize imageUrl = _imageUrl;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setImageUrl:(NSArray *)imageUrl{
    _imageUrl = [imageUrl copy];
    NSArray *arr = [self.imageViews subviews];
    for (int j=0;j< arr.count;j++){
        [arr[j] removeFromSuperview];
    }
    self.imageHeightConstraint.constant = _imageUrl.count * 134;
    for (int i = 0;i<_imageUrl.count;i++){
        UIImageView *image = [[UIImageView alloc] init];
        [image sd_setImageWithURL:_imageUrl[i][@"img"]];
        [self.imageViews addSubview:image];
        image.frame = CGRectMake(0,i*134,100,134);
    }
}
@end
