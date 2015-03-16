//
//  Message.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/12.
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
@property (nonatomic, retain) Friends *user;
@property (nonatomic, retain) Chat *chat;

@end
