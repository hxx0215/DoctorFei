//
//  Message.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/6.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createtime;
@property (nonatomic, retain) NSNumber * flag;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) Friends *user;

@end
