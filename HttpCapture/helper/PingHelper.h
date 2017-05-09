//
//  PingHelper.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/26.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBPing.h"

@protocol PingDelegate <NSObject>

- (void)pingLogCallBack:(NSString *)log;

- (void)pingDidEnd;

@end

@interface PingHelper : NSObject<PingDelegate>

@property(nonatomic,retain)GBPing * ping;

@property(nonatomic,weak)id<PingDelegate> pingDelegate;

- (void)toPing:(NSString *)host;

- (void)stopping;

+ (instancetype)shareInstance;

@end
