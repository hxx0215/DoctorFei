//
//  Groups.h
//  DoctorFei_Patient_iOS
//
//  Created by GuJunjia on 15/3/3.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends;

@interface Groups : NSManagedObject

@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) Friends *member;

@end
