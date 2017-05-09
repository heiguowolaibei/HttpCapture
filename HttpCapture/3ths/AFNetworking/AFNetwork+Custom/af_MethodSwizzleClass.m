//
//  af_MethodSwizzleClass.m
//  weixindress
//
//  Created by 杜永超 on 16/2/18.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "af_MethodSwizzleClass.h"
#import "UIKit/UIKit.h"

#pragma mark - iOS7 NSURLSessionTask添加属性setter和getter
/**
 iOS7 的 NSURLSessionDataTask 继承关系与iOS8+不同，因此针对iOS7添加属性
 https://github.com/AFNetworking/AFNetworking/pull/2702
 */

@interface _AFURLSessionTaskSwizzlingPropertyMethod : NSObject

@end

@implementation _AFURLSessionTaskSwizzlingPropertyMethod

+ (void)load {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) return;
    if (NSClassFromString(@"NSURLSessionTask")) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        Class currentClass = [localDataTask class];
        
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            Class superClass = [currentClass superclass];
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            if (classResumeIMP != superclassResumeIMP) {
                [self swizzleGetterAndSetterMethodForClass:currentClass];
            }
            currentClass = [currentClass superclass];
        }
        
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }
}

+ (void)swizzleGetterAndSetterMethodForClass:(Class)theClass {
    Method startGetter = class_getInstanceMethod(self, @selector(startTime_2));
    Method startSetter = class_getInstanceMethod(self, @selector(setStartTime_2:));
    Method endGetter = class_getInstanceMethod(self, @selector(endTime_2));
    Method endSetter = class_getInstanceMethod(self, @selector(setEndTime_2:));
    Method connectGetter = class_getInstanceMethod(self, @selector(connectTime_2));
    Method connectSetter = class_getInstanceMethod(self, @selector(setConnectTime_2:));
    Method objGetter = class_getInstanceMethod(self, @selector(responseObj_2));
    Method objSetter = class_getInstanceMethod(self, @selector(setResponseObj_2:));
    Method noneedGetter = class_getInstanceMethod(self, @selector(noNeedReport));
    Method noneedSetter = class_getInstanceMethod(self, @selector(setNoNeedReport:));
    Method extensionGetter = class_getInstanceMethod(self, @selector(extensionMessage));
    Method extensionSetter = class_getInstanceMethod(self, @selector(setExtensionMessage:));
    
    jd_addMethod(theClass, @selector(startTime_2), startGetter);
    jd_addMethod(theClass, @selector(setStartTime_2:), startSetter);
    jd_addMethod(theClass, @selector(endTime_2), endGetter);
    jd_addMethod(theClass, @selector(setEndTime_2:), endSetter);
    jd_addMethod(theClass, @selector(connectTime_2), connectGetter);
    jd_addMethod(theClass, @selector(setConnectTime_2:), connectSetter);
    jd_addMethod(theClass, @selector(responseObj_2), objGetter);
    jd_addMethod(theClass, @selector(setResponseObj_2:), objSetter);
    jd_addMethod(theClass, @selector(noNeedReport), noneedGetter);
    jd_addMethod(theClass, @selector(setNoNeedReport:), noneedSetter);
    jd_addMethod(theClass, @selector(extensionMessage), extensionGetter);
    jd_addMethod(theClass, @selector(setExtensionMessage:), extensionSetter);
}
-(NSString *) extensionMessage {
    return objc_getAssociatedObject(self, _cmd);
}
-(void) setExtensionMessage:(NSString *) extensionMessage {
    objc_setAssociatedObject(self, @selector(extensionMessage), extensionMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSTimeInterval) startTime_2 {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
-(void) setStartTime_2:(NSTimeInterval) start {
    objc_setAssociatedObject(self, @selector(startTime_2), [NSNumber numberWithDouble:start], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSTimeInterval) endTime_2 {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
-(void) setEndTime_2:(NSTimeInterval) endTime_2 {
    objc_setAssociatedObject(self, @selector(endTime_2), [NSNumber numberWithDouble:endTime_2], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSTimeInterval) connectTime_2 {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
-(void) setConnectTime_2:(NSTimeInterval) connectTime_2 {
    objc_setAssociatedObject(self, @selector(connectTime_2), [NSNumber numberWithDouble:connectTime_2], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(id) responseObj_2 {
    return objc_getAssociatedObject(self, _cmd);
}
-(void) setResponseObj_2:(id) responseObj {
    objc_setAssociatedObject(self, @selector(responseObj_2), responseObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL) noNeedReport {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void) setNoNeedReport:(BOOL) noNeedReport {
    objc_setAssociatedObject(self, @selector(noNeedReport), [NSNumber numberWithBool:noNeedReport], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
