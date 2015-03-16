//
//  Friends.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat, Groups, Message;

@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSDate * lastLoginTime;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * noteName;
@property (nonatomic, retain) NSString * realname;
@property (nonatomic, retain) NSString * situation;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) NSString * hospital;
@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSString * otherContact;
@property (nonatomic, retain) NSNumber * isFriend;
@property (nonatomic, retain) NSSet *chat;
@property (nonatomic, retain) Groups *group;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Friends (CoreDataGeneratedAccessors)

- (void)addChatObject:(Chat *)value;
- (void)removeChatObject:(Chat *)value;
- (void)addChat:(NSSet *)values;
- (void)removeChat:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
