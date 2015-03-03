//
//  Friends.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/3.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat, Message;

@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * noteName;
@property (nonatomic, retain) NSString * realname;
@property (nonatomic, retain) NSString * situation;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) NSDate * lastLoginTime;
@property (nonatomic, retain) Chat *chat;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSManagedObject *group;
@end

@interface Friends (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
