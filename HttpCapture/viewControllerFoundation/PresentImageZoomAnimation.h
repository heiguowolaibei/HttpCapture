//
//  SHImageZoomAnimation.h
//  SweetHouse
//
//  Created by fenyang on 13-10-31.
//  Copyright (c) 2013年 Tencent SNS iOS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol PresentZoomAnimationViewController <NSObject>

@required
- (UIImageView *) imageView;
- (CGRect)transitionViewFinalFrame;
@end

@interface PresentImageZoomAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (weak, nonatomic, readonly) UIImageView *referenceImageView;
// Initializes the receiver with the specified reference image view.
- (id)initWithReferenceImageView:(UIImageView *)referenceImageView;

@end
