//
//  SocketConnection.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/12/4.
//
//
#define kSocketAddress @"113.105.159.115"//@"115.159.0.61"
#define kSocketPort 20013
#define kSendKeepAliveDuration 30
#import "SocketConnection.h"
#import "DeviceUtil.h"
#import <JSONKit.h>
#import "FetchChatUtil.h"
#import <Reachability.h>

@interface SocketConnection ()
    <GCDAsyncSocketDelegate>
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation SocketConnection
{
    BOOL isAlive;
}
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
    if ([self.socket isConnected]){
        [self.socket disconnect];
    }
    if (![self.socket connectToHost:kSocketAddress onPort:kSocketPort error:&error]) {
        NSLog(@"%@",error.localizedDescription);
    }else{
        isAlive = YES;
    }
}

- (void)sendKeepAlive {
    NSDictionary *dict = @{
                           @"sn": [DeviceUtil getUUID],
                           @"type": @(0)
                           };
    NSData *data = [dict JSONData];
    if ([self.socket isDisconnected] || !isAlive) {
        NSLog(@"Reconnect Socket!!!");
        [self connectSocket];
    }
    [self.socket writeData:data withTimeout:kSendKeepAliveDuration tag:0];
//    [self.socket readDataWithTimeout:-1 tag:0];
    isAlive = NO;
    NSLog(@"SendKeepAlive");
//    dict = @{
//                           @"sn": [DeviceUtil getUUID],
//                           @"type": @(1)
//                           };
//    data = [dict JSONData];
//    [self.socket writeData:data withTimeout:kSendKeepAliveDuration tag:0];
}

- (void)sendCheckMessages {
    NSDictionary *dict = @{
                           @"sn": [DeviceUtil getUUID],
                           @"type": @(1)
                           };
    NSData *data = [dict JSONData];
    if ([self.socket isDisconnected] || !isAlive) {
        NSLog(@"Reconnect Socket!!!");
        [self connectSocket];
    }
    [self.socket writeData:data withTimeout:kSendKeepAliveDuration tag:0];
    //    [self.socket readDataWithTimeout:-1 tag:0];
    isAlive = NO;
    NSLog(@"SendCheckMessages");
}

- (void)beginListen {
    if ([self.socket isDisconnected]) {
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
    isAlive = YES;
    [sock readDataWithTimeout:-1 tag:0];
    if (![string isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"FetchChatCompleteNotification" object:nil];
        NSDictionary *result = [string objectFromJSONString];
        if ([result[@"verification"]boolValue] && [result[@"error"]isEqual:[NSNull null]]) {
            NSArray *dataArray = result[@"data"];
//            NSLog(@"%@",dataArray);
            for (NSDictionary *dict in dataArray) {
                [FetchChatUtil fetchChatWithParmas:dict];
            }
        }
        else{
            NSLog(@"%@",result[@"error"]);
        }

    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Socket Disconnect: %@",err);
    isAlive = NO;
}
@end
