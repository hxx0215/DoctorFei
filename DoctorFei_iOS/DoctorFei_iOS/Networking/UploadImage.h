//
//  UploadImage.h
//  DoctorFei_iOS
//
//  Created by hxx on 12/12/14.
//
//

#import <Foundation/Foundation.h>

@interface UploadImage : NSObject
+(instancetype)sharedInstance;
- (void)uploadImage:(UIImage *)image completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))complete;
@end
