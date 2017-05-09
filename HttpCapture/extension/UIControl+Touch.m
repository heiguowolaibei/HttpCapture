//
//  UIControl+Touch.m
//  weixindress
//
//  Created by liuyihao1216 on 16/6/23.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "UIControl+Touch.h"
#import <objc/runtime.h>

#define defaultInterval 0.3  //默认时间间隔

@interface UIControl()
/**bool 类型   设置是否执行点UI方法*/
@property (nonatomic, assign) BOOL isIgnoreEvent;
@end
@implementation UIControl (touch)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selA = @selector(sendAction:to:forEvent:);
        SEL selB = @selector(mySendAction:to:forEvent:);
        Method methodA = class_getInstanceMethod(self,selA);
        Method methodB = class_getInstanceMethod(self, selB);
        BOOL isAdd = class_addMethod(self, selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        if (isAdd) {
            class_replaceMethod(self, selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }else{
            method_exchangeImplementations(methodA, methodB);
        }
    });
}
- (NSTimeInterval)timeInterval
{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    objc_setAssociatedObject(self, @selector(timeInterval), @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)mySendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if ([self isKindOfClass:[UIControl class]] && [self isOpenRepeatFilter])
    {
        NSLog(@"self.isIgnoreEvent = %i",[self isIgnoreEvent]);
        if ([self isIgnoreEvent]) return;
        self.timeInterval = self.timeInterval ==0 ?defaultInterval:self.timeInterval;
        
        if (self.timeInterval > 0)
        {
            [self setIsIgnoreEvent:1];
            [self performSelector:@selector(setIsIgnoreEvent:) withObject:0 afterDelay:self.timeInterval];
        }
    }
    [self mySendAction:action to:target forEvent:event];
    
}
- (void)setIsIgnoreEvent:(int)isIgnoreEvent{
    objc_setAssociatedObject(self, "abc", @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)isIgnoreEvent{
    return [objc_getAssociatedObject(self, "abc") intValue];
}
- (void)setIsOpenRepeatFilter:(BOOL)isOpenRepeatFilter{
    objc_setAssociatedObject(self, @selector(isOpenRepeatFilter), @(isOpenRepeatFilter), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isOpenRepeatFilter{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj)
    {
        return [obj boolValue];
    }
    return false;
}

@end

