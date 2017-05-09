//
//  AFURLRequestSerialization+Custom.m
//  weixindress
//
//  Created by 杨帆 on 16/3/17.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFURLRequestSerialization+Custom.h"
#import "HttpCapture-Swift.h"

@interface AFHTTPRequestSerializer ()
@property (readwrite, nonatomic, strong) NSMutableSet *mutableObservedChangedKeyPaths;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;
@property (readwrite, nonatomic, assign) AFHTTPRequestQueryStringSerializationStyle queryStringSerializationStyle;

@end

@implementation AFHTTPRequestSerializer (Custom)

+(void)load {
    SEL originalSelector = @selector(requestWithMethod:URLString:parameters:error:);
    SEL swizzledSelector = @selector(jd_requestWithMethod:URLString:parameters:error:);
    jd_swizzleSelector([self class], originalSelector, swizzledSelector);
}

- (NSMutableURLRequest *)jd_requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error
{
    NSString *newURLString = URLString;
    NSMutableURLRequest *mutableRequest = [self jd_requestWithMethod:method URLString:newURLString parameters:parameters error:error];
    if (self.isNoCache) {
        mutableRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    return mutableRequest;
}

-(BOOL)isNoCache {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setIsNoCache:(BOOL)isNoCache {
    objc_setAssociatedObject(self, @selector(isNoCache), [NSNumber numberWithBool:isNoCache], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
