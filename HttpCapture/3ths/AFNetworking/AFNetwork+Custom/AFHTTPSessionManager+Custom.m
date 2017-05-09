//
//  AFHTTPSessionManager+Custom.m
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFHTTPSessionManager+Custom.h"
#import <objc/runtime.h>
#import "HttpCapture-swift.h"
#import "af_MethodSwizzleClass.h"
@implementation AFHTTPSessionManager(Custom)

+(void)load {
    SEL originalSelector = NSSelectorFromString(@"dataTaskWithHTTPMethod:URLString:parameters:success:failure:");
    SEL swizzledSelector = NSSelectorFromString(@"jd_dataTaskWithHTTPMethod:URLString:parameters:success:failure:");
    jd_swizzleSelector([self class], originalSelector, swizzledSelector);
    
    SEL originalSelector2 = @selector(URLSession:task:didCompleteWithError:);
    SEL swizzledSelector2 = @selector(jd_URLSession:task:didCompleteWithError:);
    jd_swizzleSelector([self class], originalSelector2, swizzledSelector2);
    
    SEL originalSelector3 = NSSelectorFromString(@"taskDidResume:");
    SEL swizzledSelector3 = @selector(jd_taskDidResume:);
    jd_swizzleSelector([self class], originalSelector3, swizzledSelector3);
    
    SEL originalSelector4 = NSSelectorFromString(@"URLSession:dataTask:didReceiveResponse:completionHandler:");
    SEL swizzledSelector4 = @selector(jd_URLSession:dataTask:didReceiveResponse:completionHandler:);
    jd_swizzleSelector([self class], originalSelector4, swizzledSelector4);
}

-(void)setIsNoCache:(BOOL)isNoCache {
    objc_setAssociatedObject(self, @selector(isNoCache), [NSNumber numberWithBool:isNoCache], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)isNoCache {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setNeedAddToken:(BOOL)needAddToken {
    objc_setAssociatedObject(self, @selector(needAddToken), [NSNumber numberWithBool:needAddToken], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)needAddToken {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(BOOL)bOpenDefaultModel {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setBOpenDefaultModel:(BOOL)bOpenDefaultModel {
    objc_setAssociatedObject(self, @selector(bOpenDefaultModel), [NSNumber numberWithBool:bOpenDefaultModel], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDataTask *)jd_dataTaskWithHTTPMethod:(NSString *)method
                                          URLString:(NSString *)URLString
                                         parameters:(id)parameters
                                            success:(void (^)(NSURLSessionDataTask *, id))success
                                            failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self jd_dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
}

- (void)jd_URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    [self jd_URLSession:session task:task didCompleteWithError:error];
//    [JDHTTPMonitor reportNetworkSpeedWithOperation:nil orTask:task];
}


- (void)jd_taskDidResume:(NSNotification *)notification
{
    [self jd_taskDidResume:notification];
}


- (void)jd_URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self jd_URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}


@end






