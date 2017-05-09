//
//  UIView+SwizzleMethod.m
//  QQMSFContact
//
//  Created by yanyang on 13-12-16.
//
//

#import "UIView+SwizzleMethod.h"
#import <mach/mach_init.h>
#import <pthread.h>
#import "WXMacroVener.h"

@implementation UIView (SwizzleMethod)

- (void)WXSetBounds:(CGRect)bounds
{
    if (isnan(bounds.origin.x)) {
        bounds.origin.x = self.bounds.origin.x;
    }
    if (isnan(bounds.origin.y)) {
        bounds.origin.y = self.bounds.origin.y;
    }
    if (isnan(bounds.size.width)) {
        bounds.size.width = self.bounds.size.width;
    }
    if (isnan(bounds.size.height)) {
        bounds.size.height = self.bounds.size.height;
    }
    
    
    [self WXSetBounds:bounds];
}

- (void)WXSetFrame:(CGRect)frame
{
    CGRect orignal = self.frame;
    if (isnan(frame.origin.x)) {
        frame.origin.x = orignal.origin.x;
    }
    if (isnan(frame.origin.y)) {
        frame.origin.y = orignal.origin.y;
    }
    if (isnan(frame.size.width)) {
        frame.size.width = orignal.size.width;
    }
    if (isnan(frame.size.height)) {
        frame.size.height = orignal.size.height;
    }
    
    [self WXSetFrame:frame];
}

- (void)addWXSubView:(UIView*)view
{
    if(self != view){
        [self addWXSubView:view];
    }
}

- (void)validateThread
{
    if (![NSThread isMainThread]){
        pthread_t thread = pthread_from_mach_thread_np(mach_thread_self());
        char buf[16] = {0};
        pthread_getname_np(thread, buf, sizeof(buf));
        if (strcmp(buf, "WebThread") != 0 && SYSTEM_VERSION >= 6.0f) {
            NSAssert(NO, @"UI operation in thread");
        }
    }
}

- (void)my_setNeedsDisplay
{
    [self validateThread];
    [self my_setNeedsDisplay];
}

- (void)my_layoutSubviews
{
    [self validateThread];
    [self my_layoutSubviews];
}

- (void)my_setNeedsLayout
{
    //[self printCallStackSymbols];
    [self validateThread];
    [self my_setNeedsLayout];
}
 
@end
