//
//  Chat.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/28.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends, GroupChat, Message;

@interface Chat : NSManagedObject

@property (nonatomic, retain) NSNumber * chatId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * unreadMessageCount;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *user;
@property (nonatomic, retain) GroupChat *groupChat;
@end

@interface Chat (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addUserObject:(Friends *)value;
- (void)removeUserObject:(Friends *)value;
- (void)addUser:(NSSet *)values;
- (void)removeUser:(NSSet *)values;

@end
