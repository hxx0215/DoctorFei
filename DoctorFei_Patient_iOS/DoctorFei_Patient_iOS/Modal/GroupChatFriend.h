//
//  GroupChatFriend.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/31.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends, GroupChat;

@interface GroupChatFriend : NSManagedObject

@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * role;
@property (nonatomic, retain) Friends *friend;
@property (nonatomic, retain) GroupChat *groupChat;

@end
