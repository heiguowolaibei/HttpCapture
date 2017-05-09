//
//  AFHTTPRequestOperationManager+Custom.m
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFHTTPRequestOperationManager+Custom.h"
#import "HttpCapture-swift.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation AFHTTPRequestOperationManager(Custom)
#pragma clang diagnostic pop

+(void)load {
    SEL originalSelector = NSSelectorFromString(@"HTTPRequestOperationWithHTTPMethod:URLString:parameters:success:failure:");
    SEL swizzledSelector = NSSelectorFromString(@"JD_HTTPRequestOperationWithHTTPMethod:URLString:parameters:success:failure:");
    jd_swizzleSelector([self class], originalSelector, swizzledSelector);
}

#pragma mark - property Setter & Getter
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
    objc_setAssociatedObject(self, @selector(bOpenDefaultModel), [NSNumber numberWithBool:bOpenDefaultModel], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
#pragma mark -
- (NSArray *)batchGET:(NSArray *)URLStringArray
           parameters:(NSArray*)parameters
        progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock
      completionBlock:(void (^)(NSArray* operations))success
{
    
    NSMutableArray *operaions = [NSMutableArray arrayWithCapacity:URLStringArray.count];
    for(int i=0;i < URLStringArray.count;i++)
    {
        NSString *URLString = URLStringArray[i];
        id parameter = parameters[i];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"GET" URLString:URLString parameters:parameter success:nil failure:nil];
        [operaions addObject:operation];
    }
    
    NSArray *arr = [AFURLConnectionOperation batchOfRequestOperations:operaions progressBlock:progressBlock completionBlock:success];
    
    for (AFURLConnectionOperation *operation in arr)
    {
        [self.operationQueue addOperation:operation];
    }
    return operaions;
}

- (AFHTTPRequestOperation *)JD_HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                        URLString:(NSString *)URLString
                                                       parameters:(id)parameters
                                                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    self.requestSerializer.isNoCache = self.isNoCache;
    
    //调用原来的函数实现，交换后JD_HTTPRequestOperationWithHTTPMethod就是原函数
    return [self JD_HTTPRequestOperationWithHTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
}

@end