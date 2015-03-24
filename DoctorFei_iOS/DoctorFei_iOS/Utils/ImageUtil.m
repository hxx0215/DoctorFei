//
//  ImageUtil.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/10.
//
//

#import "ImageUtil.h"

@implementation ImageUtil

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
+ (UIImage *)imageResizeToRetinaScreenSizeWithImage:(UIImage *)image{
    CGSize screenSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width * 2, [[UIScreen mainScreen]bounds].size.height * 2);
    UIImage *returnimage = [self scaleImage:image toSize:screenSize];
    return returnimage;
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = newSize.width/newSize.height;
    if (actualWidth > newSize.width || actualHeight > newSize.height) {
        if(imgRatio!=maxRatio){
            if(imgRatio < maxRatio){
                imgRatio = newSize.height / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = newSize.height;
            }
            else{
                imgRatio = newSize.width / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = newSize.width;
            }
        }else{
            actualWidth = newSize.width;
            actualHeight = newSize.height;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
