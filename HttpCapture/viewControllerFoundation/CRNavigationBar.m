//
//  CRNavigationBar.m
//  CRNavigationControllerExample
//
//  Created by Corey Roberts on 9/24/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "CRNavigationBar.h"
#import <objc/runtime.h>

@interface CRNavigationBar ()
@property (nonatomic, strong) CALayer *colorLayer;
@end

@implementation CRNavigationBar

static CGFloat const kDefaultColorLayerOpacity = 1.0f;
static CGFloat const kSpaceToCoverStatusBars = 20.0f;

- (BOOL)useSystemBarFrame {
    NSObject *obj = objc_getAssociatedObject(self, @selector(useSystemBarFrame));
    if (obj) {
        return ((NSNumber *)obj).boolValue;
    }
    return  false;
}

- (void)setUseSystemBarFrame:(BOOL)value {
    objc_setAssociatedObject(self, @selector(useSystemBarFrame), @(value), OBJC_ASSOCIATION_ASSIGN);
}

- (void)setFrame:(CGRect)frame
{
    if ([self useSystemBarFrame])
    {
        super.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    }
    else{
        super.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    }
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    
    if (self.colorLayer == nil) {
        self.colorLayer = [CALayer layer];
        self.colorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer addSublayer:self.colorLayer];
    }
    
    self.colorLayer.backgroundColor = barTintColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.colorLayer != nil) {
        self.colorLayer.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
        
        [self.layer insertSublayer:self.colorLayer atIndex:1];
    }
}

-(void)removeColorLayer
{
    [self.colorLayer removeFromSuperlayer];
}

- (void)displayColorLayer:(BOOL)display {
    self.colorLayer.hidden = !display;
}

@end
