//
//  Friends.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/3.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * realname;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSNumber * usertype;

@end
