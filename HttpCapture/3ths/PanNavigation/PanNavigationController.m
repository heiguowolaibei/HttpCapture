//
//  KKNavigationController.m
//  TS
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved.  MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//


#import "PanNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import <objc/runtime.h>
#import "UIViewAdditions.h"
#import "UIImage+ImageEffects.h"
#import "HttpCapture-Swift.h"
#import "UIViewAdditions.h"
#import "UINavigationController+FDFullscreenPopGesture.h"


#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

@interface PanImgModel : NSObject{
    
}

@property (retain,nonatomic) UIImage * img;
@property (retain,nonatomic) NSNumber * index;
@property (retain,nonatomic) NSString * des;
@property (retain,nonatomic) NSNumber * bDefaultImg;

@end

@implementation PanImgModel


@end

@implementation UIScrollView (pan)


- (BOOL)usePanBack {
    NSObject *obj = objc_getAssociatedObject(self, @selector(setUsePanBack:));
    if (obj) {
        return ((NSNumber *)obj).boolValue;
    }
    return  false;
}

- (void)setUsePanBack:(BOOL)value {
    objc_setAssociatedObject(self, @selector(setUsePanBack:), @(value), OBJC_ASSOCIATION_ASSIGN);
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
////    return false;
//    if (self.usePanBack)
//    {
//        UIViewController *nv = [self viewController];
//        
//        if ([nv isKindOfClass:[PersonHomePageController class]]) {
//            CGPoint p = [gestureRecognizer locationInView:nv.view];
//            if (p.x < 60 && p.x > 0 && p.y > 0) {
//                return NO;
//            }
//            else {
//                return YES;
//            }
//        }
//    }
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
    if (self.usePanBack)
    {
        UIViewController *nv = [self viewController];

        if (  [self viewController].navigationController.fd_fullscreenPopGestureRecognizer ==   otherGestureRecognizer )
        {
            if (self.contentOffset.x <= self.contentInset.left )
            {
                return true;
            }
        }
        }
    
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer  {
    if(self.usePanBack) {
        UIViewController *nv = [self viewController];
    }
    return NO;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if(self.usePanBack) {
//        UIViewController *nv = [self viewController];
//        if ([nv isKindOfClass:[PersonHomePageController class]]) {
//            if ( nv.navigationController.fd_fullscreenPopGestureRecognizer == otherGestureRecognizer )
//            {
//                CGPoint p = [gestureRecognizer locationInView:nv.view];
//                if (p.x < 60) {
//                    return YES;
//                }
//                else {
//                    return NO;
//                }
//                
//            }
//        }
//    }
//
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    return true;
}


@end



@implementation UIViewController (UIViewController_Pan)

- (BOOL)shouldPanNext {
    NSObject *obj = objc_getAssociatedObject(self, @selector(shouldPanNext));
    if (obj) {
        return ((NSNumber *)obj).boolValue;
    }
    return  false;
}

- (void)setshouldPanNext:(BOOL)value {
    objc_setAssociatedObject(self, @selector(shouldPanNext), @(value), OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)nextPageViewController {
    NSObject *obj = objc_getAssociatedObject(self, @selector(nextPageViewController));
    if (obj) {
        return ((UIViewController *)obj);
    }
    return nil;
}

- (void)setNextPageViewController:(UIViewController *)value {
    objc_setAssociatedObject(self, @selector(nextPageViewController), value, OBJC_ASSOCIATION_RETAIN);
}

//- (void)setNextPageViewControllerNil {
//    objc_setAssociatedObject(self, @selector(nextPageViewController), nil, OBJC_ASSOCIATION_ASSIGN);
//}

- (UIImage *)vcCapture{
    NSObject *obj = objc_getAssociatedObject(self, @selector(vcCapture));
    if (obj) {
        return ((UIImage *)obj);
    }
    return [UIImage imageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] size:[UIScreen mainScreen].bounds.size];
}

- (void)setVCCapture:(UIImage *)img{
    objc_setAssociatedObject(self, @selector(vcCapture),img, OBJC_ASSOCIATION_RETAIN);
}

@end

@interface PanNavigationController ()
{
    CGPoint startTouch;
    CGPoint touchPoint;
    UIView *lastScreenShotView;
    UIView *blackMask;
    float offsetValue;
    UIView * _backgroundView;
    UIView * coverView;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) UIView *coverView;
@property (nonatomic,retain) NSMutableDictionary *screenShotsDic;

@property (nonatomic,assign) BOOL isMoving;

@end

@implementation PanNavigationController

@dynamic backgroundView;
@dynamic coverView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if(self){
        
    }
    
    return self;
}

- (void)setBackgroundView:(UIView *)__backgroundView{
    if (__backgroundView == _backgroundView) {
        return;
    }
    if (_backgroundView) {
        [lastScreenShotView removeAllSubviews];
        [_backgroundView removeAllSubviews];
        
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        
        [lastScreenShotView removeFromSuperview];
        lastScreenShotView = nil;
    }
    
    _backgroundView = __backgroundView;
}

- (UIView *)backgroundView{
    return _backgroundView;
}

- (void)setCoverView:(UIView *)_coverView{
    if (_coverView == coverView) {
        return;
    }
    if (coverView) {
        [coverView removeAllSubviews];
        
        [coverView removeFromSuperview];
        coverView = nil;
    }
    
    coverView = _coverView;
}

- (UIView *)coverView{
    return coverView;
}

- (void)dealloc
{
    [self.screenShotsDic removeAllObjects];
    self.screenShotsDic = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenShotsDic = [[NSMutableDictionary alloc]init];
    offsetValue = screenWidth/4;
    
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"操作" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(buttonNormalThreadTestPressed:) forControlEvents:UIControlEventTouchUpInside];
//    btn.frame = CGRectMake(160, 0, 150, 150);
//    [self.view addSubview:btn];
//    [self.view bringSubviewToFront:btn];
    
//    self.recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
//                                                                                action:@selector(paningGestureReceive:)];
//    [self.view addGestureRecognizer:_recognizer];
//    _recognizer.delegate = self;
}

- (void)buttonNormalThreadTestPressed:(UIButton *)idd{
   
//    lastScreenShotView.image = [self.screenShotsDic lastObject];
//    lastScreenShotView.image = nil;
//    lastScreenShotView.backgroundColor = [UIColor redColor];
//    [_backgroundView bringSubviewToFront:lastScreenShotView];
//    [self.view setHidden:YES];
//    [_backgroundView setHidden:NO];
//    _backgroundView.backgroundColor = [UIColor yellowColor];
//    lastScreenShotView.frame = CGRectMake(40, 40, 200, 200);
//    [self.view.superview bringSubviewToFront:lastScreenShotView];
//    
//    [idd setBackgroundImage:[self.screenShotsList lastObject] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)moveViewWithX:(float)x
{
    if (x >= 0)
    {
        coverView.alpha = 0.15 * x/screenWidth;
        CGRect frame = self.view.frame;
        frame.origin.x = -x * 0.7;
        self.view.frame = frame;
        
        x = screenWidth - fabsf(x);
    
        [lastScreenShotView setFrame:CGRectMake(x,
                                                0,
                                                kkBackViewWidth,
                                                kkBackViewHeight)];
    }
}

-(BOOL)isBlurryImg:(CGFloat)tmp
{
    return YES;
}

#pragma mark - Gesture Recognizer -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    int count = self.viewControllers.count;
    if (count > 0)
    {
        UIViewController *cur = self.topViewController;
        if ([cur shouldPanNext] && [cur nextPageViewController]){
            return true;
        }
        
        return false;
    }
    else
    {
        return false;
    }
}

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if (self.viewControllers.count <= 1) return;
    
    [self.view resignAllFirstResponder];
    
    touchPoint = [recoginzer locationInView:KEY_WINDOW];
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        _isMoving = YES;
        startTouch = touchPoint;
        
        NSLog(@"touchPoint start = %@",NSStringFromCGPoint(touchPoint));
        
        CGRect frame = self.view.frame;
        self.backgroundView = nil;
        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
        [self.view.superview insertSubview:self.backgroundView aboveSubview:self.view];
        
        self.coverView = nil;
        self.coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0;
        [self.view addSubview:self.coverView];
        
        self.backgroundView.hidden = NO;
        
        lastScreenShotView = [[UIView alloc]init];
        [lastScreenShotView setFrame:CGRectMake(screenWidth, 0, frame.size.width, frame.size.height)];
        
        if ([self.topViewController shouldPanNext] && [self.topViewController nextPageViewController])
        {
            UIViewController * vc = [self.topViewController nextPageViewController];
            [vc.view removeFromSuperview]; 
            [lastScreenShotView addSubview:vc.view];
            vc.view.frame = lastScreenShotView.bounds;
            NSLog(@"[self nextPageViewController].view.frame = %@,%@",vc.view,vc);
        }
        
        [self.backgroundView addSubview:lastScreenShotView];
    }
    else if (recoginzer.state == UIGestureRecognizerStateEnded){
        NSLog(@"touchPoint end = %@",NSStringFromCGPoint(touchPoint));
        
        if (startTouch.x - touchPoint.x > offsetValue)
        {
            CGFloat distance = (screenWidth + self.view.left);
            
            [UIView animateWithDuration:MAX(0.1, distance/1200) animations:^{
                [self moveViewWithX:screenWidth];
            } completion:^(BOOL finished) {
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                UIViewController * nextPageViewController = [self.topViewController nextPageViewController];
                [self resetData];
                
                if (nextPageViewController != nil)
                {
                    [self pushViewController:nextPageViewController animated:false];
                }
                
            }];
        }
        else
        {
            CGFloat distance = fabs(self.view.frame.origin.x - 0);
            [UIView animateWithDuration:MAX(0.1, distance/1200) animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                [self resetData];
                
                if ([self.topViewController respondsToSelector:@selector(configRigthVC)])
                {
//                    [self.topViewController performSelector:@selector(configRigthVC) withObject:nil];
                }
            }];
        }
        return;
    }
    else if (_recognizer.state == UIGestureRecognizerStateCancelled ||
             _recognizer.state == UIGestureRecognizerStateFailed)
    {
        NSLog(@"touchPoint failcancel = %@",NSStringFromCGPoint(touchPoint));
        
        CGFloat distance = fabs(self.view.frame.origin.x - 0);
        [UIView animateWithDuration:MAX(0.1, distance/1200) animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            [self resetData];
        }];
        
        return;
    }
    
    if (_isMoving)
    {
        if (startTouch.x - touchPoint.x >= 0)
        {
            [self moveViewWithX: startTouch.x - touchPoint.x];
        }
    }
}

- (void)resetData{
    startTouch = CGPointZero;
    touchPoint = CGPointZero;
    _isMoving = NO;
    self.backgroundView = nil;
    self.coverView = nil;
   
    [self.topViewController setNextPageViewController:nil];
    
}


@end



