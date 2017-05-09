//
//  ASIHTTPRequest+Custom.m
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/16.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "NSURLConnection+Custom.h"
#import <objc/runtime.h>

@implementation NSURLConnection(Custom)

- (BOOL)isFinished{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj != nil && [obj isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)obj boolValue];
    }
    return false;
}

- (void)setISFinished:(BOOL)isfinish{
    objc_setAssociatedObject(self,@selector(isFinished),@(isfinish),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end































