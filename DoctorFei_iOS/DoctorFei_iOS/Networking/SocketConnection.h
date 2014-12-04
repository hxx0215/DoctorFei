//
//  SocketConnection.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>

@interface SocketConnection : NSObject

@property (nonatomic, strong) GCDAsyncSocket *socket;


+ (SocketConnection *)sharedConnection;

- (void)sendKeepAlive;

- (void)beginListen;
- (void)stopListen;

@end
