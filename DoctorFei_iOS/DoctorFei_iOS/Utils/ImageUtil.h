//
//  ImageUtil.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/10.
//
//

#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageResizeToRetinaScreenSizeWithImage:(UIImage *)image;
@end
