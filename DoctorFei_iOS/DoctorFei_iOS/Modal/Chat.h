//
//  Chat.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends, Message;

@interface Chat : NSManagedObject

@property (nonatomic, retain) NSString * lastMessageContent;
@property (nonatomic, retain) NSDate * lastMessageTime;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * unreadMessageCount;
@property (nonatomic, retain) NSSet *user;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Chat (CoreDataGeneratedAccessors)

- (void)addUserObject:(Friends *)value;
- (void)removeUserObject:(Friends *)value;
- (void)addUser:(NSSet *)values;
- (void)removeUser:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
