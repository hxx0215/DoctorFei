//
//  SocketConnection.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//
#define kSocketAddress @"113.105.159.115"
#define kSocketPort 20013
#define kSendKeepAliveDuration 30
#import "SocketConnection.h"
#import "DeviceUtil.h"
#import <JSONKit.h>

@interface SocketConnection ()
    <GCDAsyncSocketDelegate>
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation SocketConnection
@synthesize socket = _socket, timer = _timer;


+ (SocketConnection *)sharedConnection {
    static SocketConnection *sharedConnection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConnection = [[SocketConnection alloc]init];
    });
    return sharedConnection;
}

- (id)init {
    self = [super init];
    if (self) {
        if (self.socket == nil) {
            self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        }
    }
    return self;
}

- (void)connectSocket {
    NSError *error = nil;
    if (![self.socket connectToHost:kSocketAddress onPort:kSocketPort error:&error]) {
        NSLog(@"%@",error.localizedDescription);
    }
}

- (void)sendKeepAlive {
    NSDictionary *dict = @{
                           @"sn": [DeviceUtil getUUID],
                           @"type": @(0)
                           };
    NSData *data = [dict JSONData];
    [self.socket writeData:data withTimeout:kSendKeepAliveDuration tag:0];
    if ([self.socket isDisconnected]) {
        NSLog(@"Reconnect Socket!!!");
        [self connectSocket];
    }
    [self.socket readDataWithTimeout:-1 tag:0];
    NSLog(@"SendKeepAlive");
}

- (void)beginListen {
    if (![self.socket isConnected]) {
        [self connectSocket];
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kSendKeepAliveDuration target:self selector:@selector(sendKeepAlive) userInfo:nil repeats:YES];
}
- (void)stopListen {
    if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - GCDAsyncSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Socket Connect To Host Success");
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Socket Receive: %@", string);
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Socket Disconnect: %@",err);
}
@end
