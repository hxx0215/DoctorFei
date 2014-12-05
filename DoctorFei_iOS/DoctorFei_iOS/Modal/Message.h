//
//  Message.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createtime;
@property (nonatomic, retain) NSNumber * flag;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSString * msgType;

@end
