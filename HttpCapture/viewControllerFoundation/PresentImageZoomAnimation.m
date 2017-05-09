//
//  SHImageZoomAnimation.m
//  SweetHouse
//
//  Created by fenyang on 13-10-31.
//  Copyright (c) 2013年 Tencent SNS iOS Team. All rights reserved.
//

#import "PresentImageZoomAnimation.h"
 

@implementation PresentImageZoomAnimation

- (id)initWithReferenceImageView:(UIImageView *)referenceImageView {
    if (self = [super init]) {
        
        _referenceImageView = referenceImageView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    return viewController.isBeingPresented ? 0.3 : 0.15;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (viewController.isBeingPresented) {
        [self animateZoomInTransition:transitionContext];
    }
    else {
        [self animateZoomOutTransition:transitionContext];
    }
}

- (void)animateZoomInTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the view controllers participating in the transition
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<PresentZoomAnimationViewController> *toViewController = (UIViewController<PresentZoomAnimationViewController> *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // Create a temporary view for the zoom in transition and set the initial frame based
    // on the reference image view
    UIImageView *transitionView = [[UIImageView alloc] initWithImage:self.referenceImageView.image];
    transitionView.contentMode = UIViewContentModeScaleAspectFit;
    transitionView.clipsToBounds = YES;
    transitionView.frame = [transitionContext.containerView convertRect:self.referenceImageView.bounds
                                                               fromView:self.referenceImageView];
    [transitionContext.containerView addSubview:transitionView];
    transitionContext.containerView.backgroundColor = [UIColor whiteColor];
    
    // Compute the final frame for the temporary view
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    finalFrame.size.height -=20;
    finalFrame.origin.y +=20;
    CGRect transitionViewFinalFrame = [toViewController transitionViewFinalFrame];
    
    // Perform the transition using a spring motion effect
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromViewController.view.alpha = 0;
        
        transitionView.frame = transitionViewFinalFrame;
    } completion:^(BOOL finished) {
        fromViewController.view.alpha = 1;
        
        [transitionView removeFromSuperview];
        [transitionContext.containerView addSubview:toViewController.view];
        
        [transitionContext completeTransition:YES];

    }];
}

- (void)animateZoomOutTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the view controllers participating in the transition
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<PresentZoomAnimationViewController> *fromViewController = (UIViewController<PresentZoomAnimationViewController> *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // The toViewController view will fade in during the transition
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView sendSubviewToBack:toViewController.view];
    
    // Compute the initial frame for the temporary view based on the image view
    // of the TGRImageViewController
    CGRect b = fromViewController.imageView.bounds;
    CGRect transitionViewInitialFrame = [transitionContext.containerView convertRect:b fromView:fromViewController.imageView ];
//    transitionViewInitialFrame = [transitionContext.containerView convertRect:transitionViewInitialFrame
//                                                                     fromView:fromViewController.imageView];
    
    // Compute the final frame for the temporary view based on the reference
    // image view
    CGRect transitionViewFinalFrame = [toViewController.view convertRect:self.referenceImageView.bounds
                                                                fromView:self.referenceImageView];
    
    /*
     if (UIApplication.sharedApplication.isStatusBarHidden && ![toViewController prefersStatusBarHidden]) {
     transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20);
     }*/
    
    // Create a temporary view for the zoom out transition based on the image
    // view controller contents
    UIImageView *transitionView =  fromViewController.imageView;
    [transitionView removeFromSuperview ];
    transitionView.clipsToBounds = YES;
    transitionView.frame = transitionViewInitialFrame;
    [transitionContext.containerView addSubview:transitionView];
    
    // Perform the transition
//    NSTimeInterval duration = [self transitionDuration:transitionContext];
//    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         transitionView.frame = transitionViewFinalFrame;
                         toViewController.view.alpha = 1;
                         fromViewController.view.alpha = 0;
                     } completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                         [transitionView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
    

}

- (CGRect)image:(UIImage*)image aspectFitRectForSize:(CGSize)size {
    CGFloat targetAspect = size.width / size.height;
    CGFloat sourceAspect = image.size.width / image.size.height;
    CGRect rect = CGRectZero;
    
    if (targetAspect > sourceAspect) {
        rect.size.height = size.height;
        rect.size.width = ceilf(rect.size.height * sourceAspect);
        rect.origin.x = ceilf((size.width - rect.size.width) * 0.5);
    }
    else {
        rect.size.width = size.width;
        rect.size.height = ceilf(rect.size.width / sourceAspect);
        rect.origin.y = ceilf((size.height - rect.size.height) * 0.5);
    }
    
    return rect;
}


@end
