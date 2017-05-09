
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wbuiltin-macro-redefined"
#define __FILE__ "QQNavigationController"
#pragma clang diagnostic pop

//
//  QQNavigationController.m
//  QQMSFContact
//
//  Created by Yang Jin on 12-3-18.
//  Copyright 2012 Tencent. All rights reserved.
//


#import "QQNavigationController.h"
#import "QQNavigationController+OperationQueue.h"
#import "UINavigationController+FDFullscreenPopGesture.h"


#define USE_SYSTEM_GESTURE      1
#define SYSTEM_VERSION              8.0



@protocol QQViewControllerAnimatedTransitioningDelegate <NSObject>

- (void)animationTransitionWillStart;
- (void)animationTransitionDidEnd:(BOOL)animation;
- (void)animationDidStart;
- (void)animationDidFinished;

@end

// 自定义返回动画
@interface QQViewControllerAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>
{
    id <QQViewControllerAnimatedTransitioningDelegate>_delegate;
}
@property (nonatomic,assign)    id <QQViewControllerAnimatedTransitioningDelegate>delegate;

@end


@interface QQNavigationController()<QQViewControllerAnimatedTransitioningDelegate> {
    // 手势滑动返回
    // FTS Install Package
    /*UIView* _lastScreenShotView;*/
    UIImageView* _leftShadowMask; // 左边的阴影图
    UIView* _blackMask;
    UIView* _backgroundView;
    UIImage* _lastScreenShot; // 上一个窗口导航条+tabbar截屏
    BOOL _isMoving;
    BOOL _isTransitioning;
 
    CGFloat _offsetX;
    CGPoint _startTouch;
    CGPoint _startLocation;
    CGPoint _lastMove;
    NSTimeInterval _startTouchTime;

    
    NSMutableArray* _otherGestureRecognizers; // 其他正在执行的手势
    UIPercentDrivenInteractiveTransition* _interactivePopTransition;
    
    UINavigationControllerOperation _ftsCurrOperation;
}



// 是否支持右滑时，中途左滑回退到滑动前状态。
- (BOOL)issupportInterruputRightDragToGoBack;
@end



@implementation QQNavigationController

@synthesize isSupportRightDragToGoBack = _isSupportRightDragToGoBack;
@synthesize isTransitioning = _isTransitioning;
@synthesize popGuestureRespondWidth = _popGuestureRespondWidth;

+ (instancetype)newWithRootViewController:(UIViewController *)rootViewController {
    return [[self alloc] initWithRootViewController:rootViewController];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
	[super setNavigationBarHidden:navigationBarHidden];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
	[super setNavigationBarHidden:hidden animated:animated];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	if (self = [super initWithRootViewController:rootViewController]) {
		self.delegate = self;
	}
	
	return self;
}

- (void)updateOrientationSupportFromViewController:(UIViewController*)viewController
{
    
}

 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ex_viewDidLoad];
}

- (void)dealloc
{
    [self ex_dealloc];
 
}

- (void)loadView
{
    [super loadView];
}


- (void)hideActionSheetOrAlertViewInView:(UIView*)mainView
{
    for (UIView* subView in mainView.subviews) {
        if ([subView isKindOfClass:[UIActionSheet class]]) {
            UIActionSheet* actionSheet = (UIActionSheet*)subView;
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
        } else if ([subView isKindOfClass:[UIAlertView class]]) {
            UIAlertView* alertView = (UIAlertView*)subView;
            [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
        } else {
            [self hideActionSheetOrAlertViewInView:subView];
        }
    }
}
- (void)hideActionSheetOrAlertView
{
 
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self ex_pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    //ios8下，如果前后两个vc的orientation不一致，会调用两次pop，第二次pop加入队列将导致界面卡死
//    if (self.viewControllers.count > 1 && SYSTEM_VERSION >= 8.0) {
//        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//        UIInterfaceOrientationMask futureOrientation = [self.viewControllers[self.viewControllers.count - 2] supportedInterfaceOrientations];
//        if (futureOrientation != UIInterfaceOrientationMaskAll && futureOrientation != (1<<currentOrientation)) {
//            return [super popViewControllerAnimated:animated];
//        }
//    }
    
    return [self ex_popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    return [self ex_popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self ex_popToRootViewControllerAnimated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    //找出被pop出去的viewController们，告知他们被pop了
    [self ex_setViewControllers:viewControllers animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _isTransitioning = YES;
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _isTransitioning = NO;
    [self didShowViewController:viewController];
    _ftsCurrOperation = UINavigationControllerOperationNone;
}

-(BOOL)isPanning
{
//    return false;
    return [self fd_inTransitionPaning];
}



- (UIViewController*)findViewContrlloer:(NSString*)name
{
    Class class = NSClassFromString(name);
	for (UIViewController *subviewCtr in self.viewControllers) {
        if ([subviewCtr isKindOfClass:class]) {
            return subviewCtr;
        }
	}
    return nil;
}





@end



 
