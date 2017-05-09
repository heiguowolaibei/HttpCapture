//
//  HostResoluteHelper.m
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/29.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "HostResoluteHelper.h"
#import "HostResoluteOperation.h"

@interface HostResoluteHelper(){
    __block HostResoluteOperation * obj;
}

@end

@implementation HostResoluteHelper

- (void)parseHost:(NSString *)host block:(QQHostResolutionOperationCallback)block{
    obj = [[HostResoluteOperation alloc] initWithHostName:host];
    [obj startWithCallback:^(QQHostInfoResolutionType type, id objj, double time)
    {
        block(type,objj,time);
        [obj release];
        obj = nil;
    }];
}



@end
