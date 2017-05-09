//
//  UINavigationBar+Awesome.m
//  LTNavigationBar
//
//  Created by ltebean on 15-2-15.
//  Copyright (c) 2015 ltebean. All rights reserved.
//

#import "UINavigationBar+Awesome.h"
#import <objc/runtime.h>
#import "HttpCapture-swift.h"

@implementation UINavigationBar (Awesome)
static char overlayKey;

- (UIView *)overlay
{
    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)setOverlay:(UIView *)overlay
{
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lt_setBackgroundColor:(UIColor *)backgroundColor
{
    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.bounds) + 20)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.overlay atIndex:0];
    }
    if (self.overlay.superview == nil) {
        [self insertSubview:self.overlay atIndex:0];
    }
    
    self.overlay.backgroundColor = backgroundColor;
}

- (void)lt_removeBackgroundColor
{
    if (self.overlay) {
        [self.overlay removeFromSuperview];
    }
}

- (void)lt_setTranslationY:(CGFloat)translationY
{
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

- (void)lt_setElementsAlpha:(CGFloat)alpha
{
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha = alpha;
}

- (void)lt_reset
{
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}

- (nullable UIImageView *)getBottomImageOfNavigationBar {
    
    id _backgroundView = [self valueForKey:@"_backgroundView"];
    if (_backgroundView != nil && [_backgroundView isKindOfClass:[UIView class]] ) {
        id bgImgView = [_backgroundView valueForKey:@"_shadowView"];
        if (bgImgView != nil && [bgImgView isKindOfClass:[UIImageView class]]) {
            return (UIImageView *)bgImgView;
        }
    }
    
    return nil;
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    
    if (CGRectContainsPoint(CGRectMake((self.width-44)/2.0, 20, 44, 44), point)) {
        UIViewController *topVC = [self viewController];
        
        
    }
    return v;
}

@end
