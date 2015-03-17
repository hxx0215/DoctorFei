//
//  Message.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat, Friends;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createtime;
@property (nonatomic, retain) NSNumber * flag;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) Chat *chat;
@property (nonatomic, retain) Friends *user;

@end
