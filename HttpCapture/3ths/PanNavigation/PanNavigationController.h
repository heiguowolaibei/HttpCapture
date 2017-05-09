//
//  KKNavigationController.h
//  TS
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved. MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//

#import <UIKit/UIKit.h>
#import "BaseNavigationController.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define kkBackViewHeight [UIScreen mainScreen].bounds.size.height
#define kkBackViewWidth [UIScreen mainScreen].bounds.size.width

#define iOS7  ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

// 背景视图起始frame.x
#define startX -((kkBackViewWidth)/4*3);

@interface UIViewController (UIViewController_Pan)

- (BOOL)shouldPanNext;
- (void)setshouldPanNext:(BOOL)value;
- (void)setVCCapture:(UIImage *)img;
- (UIImage *)vcCapture;
- (UIViewController *)nextPageViewController;
- (void)setNextPageViewController:(UIViewController *)value;

@end


@interface UIScrollView (pan)
- (BOOL)usePanBack;
- (void)setUsePanBack:(BOOL)value;
@end

@protocol PanNavigationControllerDelegate <NSObject>

@optional

- (void)onNotificateVCIsPanPop;

@end

@interface PanNavigationController : BaseNavigationController<UIGestureRecognizerDelegate>
{

}

// 默认为特效开启
@property (nonatomic,strong)UIPanGestureRecognizer *recognizer;
@property (nonatomic, weak) id<PanNavigationControllerDelegate> panDelegate;

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer;

@end
