//
//  AFURLConnectionOperation+Custom.m
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFURLConnectionOperation+Custom.h"
#import <objc/runtime.h>
#import "HttpCapture-Swift.h"

@implementation AFURLConnectionOperation(Custom)

+(void)load{
    SEL originalSelector = NSSelectorFromString(@"connection:didReceiveResponse:");
    SEL swizzledSelector = @selector(jd_connection:didReceiveResponse:);
    jd_swizzleSelector([self class], originalSelector, swizzledSelector);
    
    SEL originalSelector2 = NSSelectorFromString(@"finish");
    SEL swizzledSelector2 = @selector(jd_finish);
    jd_swizzleSelector([self class], originalSelector2, swizzledSelector2);
    
    SEL originalSelector3 = NSSelectorFromString(@"operationDidStart");
    SEL swizzledSelector3 = @selector(jd_operationDidStart);
    jd_swizzleSelector([self class], originalSelector3, swizzledSelector3);
}

-(void)setSextra:(NSString *)sextra {
    objc_setAssociatedObject(self, @selector(sextra), sextra, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)sextra {
    if (objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, @"", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setSextra2:(NSString *)sextra2 {
    objc_setAssociatedObject(self, @selector(sextra2), sextra2, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

-(NSString *)sextra2 {
    if (objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, @"", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setStartTime:(NSTimeInterval)startTime {
    objc_setAssociatedObject(self, @selector(startTime), [NSNumber numberWithDouble:startTime], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

-(NSTimeInterval)startTime {
    if (objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, [NSNumber numberWithDouble:0], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
-(void)setConnectTime:(NSTimeInterval)connectTime {
    objc_setAssociatedObject(self, @selector(connectTime), [NSNumber numberWithDouble:connectTime], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

-(NSTimeInterval)connectTime {
    if (objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, [NSNumber numberWithDouble:0], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
-(void)setEndTime:(NSTimeInterval)endTime {
    objc_setAssociatedObject(self, @selector(endTime), [NSNumber numberWithDouble:endTime], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

-(NSTimeInterval)endTime {
    if (objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, [NSNumber numberWithDouble:0], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

-(BOOL)bOpenDefaultModel {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setBOpenDefaultModel:(BOOL)bOpenDefaultModel {
    objc_setAssociatedObject(self, @selector(bOpenDefaultModel), [NSNumber numberWithBool:bOpenDefaultModel], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)jd_connection:(NSURLConnection __unused *)connection
didReceiveResponse:(NSURLResponse *)response
{
    self.connectTime = [[NSDate date] timeIntervalSince1970];
    [self jd_connection:connection didReceiveResponse:response];
}
- (void)jd_operationDidStart {
    self.startTime = [[NSDate date] timeIntervalSince1970];
    [self jd_operationDidStart];
}

- (void)jd_finish {
    self.endTime = [[NSDate date] timeIntervalSince1970];
//    [JDHTTPMonitor reportNetworkSpeedWithOperation:self orTask:nil];
    [self jd_finish];
}
@end
