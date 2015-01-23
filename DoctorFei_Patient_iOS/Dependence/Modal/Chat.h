//
//  Chat.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/6.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends;

@interface Chat : NSManagedObject

@property (nonatomic, retain) NSString * lastMessageContent;
@property (nonatomic, retain) NSDate * lastMessageTime;
@property (nonatomic, retain) NSNumber * unreadMessageCount;
@property (nonatomic, retain) Friends *user;

@end
