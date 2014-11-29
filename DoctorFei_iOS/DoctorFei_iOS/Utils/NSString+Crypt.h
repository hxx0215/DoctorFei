//
//  NSString+Crypt.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/28.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Crypt)
+(NSString *)createResponseURLWithMethod:(NSString *)method Params:(NSString *)params;
- (NSString *)decryptWithDES;
+ (NSString *)decodeFromPercentEscapeString: (NSString *) input;
@end
