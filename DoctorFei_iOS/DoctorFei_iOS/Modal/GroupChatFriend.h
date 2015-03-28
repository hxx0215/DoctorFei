//
//  GroupChatFriend.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/28.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends, GroupChat;

@interface GroupChatFriend : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * role;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) GroupChat *groupChat;
@property (nonatomic, retain) Friends *friend;

@end
