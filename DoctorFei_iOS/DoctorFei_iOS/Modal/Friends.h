//
//  Friends.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * realname;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * userType;

@end
