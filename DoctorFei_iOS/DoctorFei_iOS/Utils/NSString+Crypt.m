//
//  NSString+Crypt.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/28.
//
//

#define KeyStr @"feiyi#8("
#define baseURL @"http://113.105.159.115:5027"
//#define baseURL @"http://api.feiyisheng.com:82"
#import "NSString+Crypt.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (Crypt)


+(NSString *)createResponseURLWithMethod:(NSString *)method Params:(NSString *)params{
    NSString *retStr;
    NSString *paramsStr = [[NSString encodeToPercentEscapeString:params] encryptWithDES];
    NSString *sign = [NSString createSignWithMethod:method Params:paramsStr];
    if (params && [params length]>0){
        retStr = [NSString stringWithFormat:@"%@?Method=%@&Params=%@&Sign=%@",baseURL,method,paramsStr,sign];
    }
    else
        retStr = [NSString stringWithFormat:@"%@?Method=%@&Sign=%@",baseURL,method,sign];
    return retStr;
}
+ (NSString *)encodeToPercentEscapeString:(NSString *)input{
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return [outputStr lowercasePercent];
}

- (NSString *)lowercasePercent{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *myByte = (Byte *)[data bytes];
    int i=0;
    int length = (int)[data length];
    while (i<[data length]){
        if (myByte[i] == '%')
        {
            i++;
            if ((myByte [i]>='A')&&(myByte [i]<='Z'))
                myByte[i]=myByte[i]-'A'+'a';
            i++;
            if ((myByte [i]>='A')&&(myByte [i]<='Z'))
                myByte[i]=myByte[i]-'A'+'a';
        }
        i++;
    }
    data = [NSData dataWithBytes:myByte length:length];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

- (NSString *)encryptWithDES{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vinitVec = (const void *) [KeyStr UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       [KeyStr UTF8String],
                       kCCKeySizeDES,
                       vinitVec,
                       [self UTF8String],
                       [self length],
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free(bufferPtr);
    return [[myData description] formatData];
}
- (NSString *)formatData{
    NSMutableString *str=[self mutableCopy];
    NSString *rangeStr1 = @"<";
    NSString *rangeStr2 = @">";
    NSString *rangeStr3 = @" ";
    NSRange range = [str rangeOfString:rangeStr1];
    [str deleteCharactersInRange:range];
    range = [str rangeOfString:rangeStr2];
    [str deleteCharactersInRange:range];
    range = [str rangeOfString:rangeStr3];
    while (range.location != NSNotFound){
        [str deleteCharactersInRange:range];
        range = [str rangeOfString:rangeStr3];
    }
    return [str uppercaseString];
}

- (NSString *) stringFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (NSString *)createSignWithMethod:(NSString *)method Params:(NSString *)params{
    NSString *str;
    assert(method != nil);
    if (params && [params length]>0){
        str = [NSString stringWithFormat:@"%@Method%@Params%@%@",KeyStr,method,params,KeyStr];
    }
    else{
        str = [NSString stringWithFormat:@"%@Method%@%@",KeyStr,method,KeyStr];
    }
    return [[str stringFromMD5] uppercaseString];
}

#pragma mark - decrypt
- (NSString *)decryptWithDES{
    NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding];
    char *vplainText = strdup([self UTF8String]);//calloc([self length] * sizeof(char) + 1);
    //    strcpy(vplainText, [self UTF8String]);
    char *plain = malloc([self length] / 2 *sizeof(char));
    for (int i=0;i<[self length] / 2;i++)
    {
        int a=0;
        if (vplainText[i * 2]>='A' && vplainText[i * 2]<='Z')
            a = vplainText[i * 2] - 'A' + 10;
        if (vplainText[i * 2]>='0' && vplainText[i * 2]<='9')
            a = vplainText[i * 2] - '0';
        int b=0;
        if (vplainText[i * 2 + 1]>='A' && vplainText[i * 2 + 1]<='Z')
            b = vplainText[i * 2 + 1] - 'A' + 10;
        if (vplainText[i * 2 + 1]>='0' && vplainText[i * 2 + 1]<='9')
            b = vplainText[i * 2 + 1] - '0';
        plain[i] = a * 16 + b;
    }
    free(vplainText);
    CCCryptorStatus ccStatus;
    const void *vinitVec = (const void *) [KeyStr UTF8String];
    size_t plainTextBufferSize = [data length];
    size_t bufferPtrSize = 0;
    uint8_t *bufferPtr = NULL;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       [KeyStr UTF8String],
                       kCCKeySizeDES,
                       vinitVec,
                       plain,
                       [self length] / 2,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    free(plain);
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free(bufferPtr);
    NSString *ret = [[NSString alloc] initWithData:myData encoding:NSASCIIStringEncoding];
    return ret;
}
+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
