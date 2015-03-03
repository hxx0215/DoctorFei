//
//  Chat.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/3.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends, Message;

@interface Chat : NSManagedObject

@property (nonatomic, retain) NSString * lastMessageContent;
@property (nonatomic, retain) NSDate * lastMessageTime;
@property (nonatomic, retain) NSNumber * unreadMessageCount;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Friends *user;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Chat (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
