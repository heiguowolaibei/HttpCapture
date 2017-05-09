//
//  PingHelper.m
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/26.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "PingHelper.h"

@interface PingHelper()
{
    NSTimer * timer;
}

@end


@implementation PingHelper

+ (instancetype)shareInstance
{
    static PingHelper* m;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [[PingHelper alloc] init];
    });
    return m;
}

- (void)invidateTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)toPing:(NSString *)host{
    [self invidateTimer];
    [self stopping];
    
    self.ping = [[GBPing alloc] init];
    self.ping.host = host;
    self.ping.delegate = self;
    self.ping.timeout = 1.0;
    self.ping.pingPeriod = 0.9;
    
    [self.ping setupWithBlock:^(BOOL success, NSError *error) { //necessary to resolve hostname
        if (success) {
            [self.ping startPinging];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(stopping) userInfo:nil repeats:NO];
        }
        else {
            NSLog(@"failed to start");
        }
    }];
}

- (void)stopping{
    [self invidateTimer];
    NSLog(@"stop it");
    if (self.ping) {
        [self.ping stop];
        self.ping = nil;
        [self.pingDelegate pingDidEnd];
    }
}

-(void)ping:(GBPing *)pinger didReceiveReplyWithSummary:(GBPingSummary *)summary {
    NSLog(@"REPLY>  %@", summary);
    [self.pingDelegate pingLogCallBack:summary.description];
}

-(void)ping:(GBPing *)pinger didReceiveUnexpectedReplyWithSummary:(GBPingSummary *)summary {
    NSLog(@"BREPLY> %@", summary);
    [self.pingDelegate pingLogCallBack:summary.description];
}

-(void)ping:(GBPing *)pinger didSendPingWithSummary:(GBPingSummary *)summary {
    NSLog(@"SENT>   %@", summary);
    [self.pingDelegate pingLogCallBack:summary.description];
}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary {
    NSLog(@"TIMOUT> %@", summary);
    [self.pingDelegate pingLogCallBack:summary.description];
}

-(void)ping:(GBPing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"FAIL>   %@", error);
    [self.pingDelegate pingLogCallBack:error.description];
}

-(void)ping:(GBPing *)pinger didFailToSendPingWithSummary:(GBPingSummary *)summary error:(NSError *)error {
    NSLog(@"FSENT>  %@, %@", summary, error);
    [self.pingDelegate pingLogCallBack:error.description];
}



@end
