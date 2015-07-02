//
//  JSQPhotoMediaSDWebImageItem.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/7/2.
//
//

#import "JSQPhotoMediaSDWebImageItem.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

@implementation JSQPhotoMediaSDWebImageItem

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        _imageView = [[UIImageView alloc] initWithImage:self.image];
        _imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:_imageView isOutgoing:[super appliesMediaViewMaskAsOutgoing]];
//        self.cachedImageView = imageView;
    }
    return _imageView;
}
- (UIView *)mediaView
{
    return _imageView;
}
- (UIView *)mediaPlaceholderView
{
    return _imageView;
}
@end
