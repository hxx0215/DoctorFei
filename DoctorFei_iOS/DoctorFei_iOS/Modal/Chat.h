//
//  Chat.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chat : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * lastMessageContent;
@property (nonatomic, retain) NSDate * lastMessageTime;
@property (nonatomic, retain) NSString * situation;
@property (nonatomic, retain) NSNumber * unreadMessageCount;

@end
