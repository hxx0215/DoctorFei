//
//  GroupChat.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/5/6.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat, GroupChatFriend;

@interface GroupChat : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * flag;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * taxis;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) Chat *chat;
@property (nonatomic, retain) NSSet *member;
@end

@interface GroupChat (CoreDataGeneratedAccessors)

- (void)addMemberObject:(GroupChatFriend *)value;
- (void)removeMemberObject:(GroupChatFriend *)value;
- (void)addMember:(NSSet *)values;
- (void)removeMember:(NSSet *)values;

@end
