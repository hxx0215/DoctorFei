//
//  MessagesModalData.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/6.
//
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"

@interface MessagesModalData : NSObject

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) NSDictionary *users;

@end
