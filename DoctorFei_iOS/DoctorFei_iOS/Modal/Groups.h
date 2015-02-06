//
//  Groups.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/2/7.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends;

@interface Groups : NSManagedObject

@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSSet *member;
@end

@interface Groups (CoreDataGeneratedAccessors)

- (void)addMemberObject:(Friends *)value;
- (void)removeMemberObject:(Friends *)value;
- (void)addMember:(NSSet *)values;
- (void)removeMember:(NSSet *)values;

@end
