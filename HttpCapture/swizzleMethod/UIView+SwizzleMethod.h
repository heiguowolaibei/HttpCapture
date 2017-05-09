//
//  UIView+SwizzleMethod.h
//  QQMSFContact
//
//  Created by yanyang on 13-12-16.
//
//

#import <UIKit/UIKit.h>

@interface UIView (SwizzleMethod)

- (void)WXSetBounds:(CGRect)bounds;
- (void)WXSetFrame:(CGRect)frame;

- (void)addWXSubView:(UIView*)view;
- (void)my_setNeedsDisplay;
- (void)my_layoutSubviews;
- (void)my_setNeedsLayout;

@end
