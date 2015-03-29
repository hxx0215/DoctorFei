//
//  GroupChat.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/28.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat, GroupChatFriend;

@interface GroupChat : NSManagedObject

@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSSet *member;
@property (nonatomic, retain) Chat *chat;
@end

@interface GroupChat (CoreDataGeneratedAccessors)

- (void)addMemberObject:(GroupChatFriend *)value;
- (void)removeMemberObject:(GroupChatFriend *)value;
- (void)addMember:(NSSet *)values;
- (void)removeMember:(NSSet *)values;

@end
