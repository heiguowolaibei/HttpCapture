//
//  BaseNavigationController.m
//


#import "BaseNavigationController.h"
#import "UIViewAdditions.h"
#import "CRNavigationBar.h"
#import "HttpCapture-Swift.h"
#import "PresentImageZoomAnimation.h"
#import "UIImage+Crop.h"

#define USE_SYSTEM_GESTURE  0 //不启用系统手势返回
#define MINSYSTEMVERSION 10.0

typedef void (^APTransitionBlock)(void);

@interface BaseNavigationController () <PresentZoomAnimationViewController> {
    BOOL _transitionInProgress;
    NSMutableArray *_peddingBlocks;
    NSMutableArray *_peedingOperation;
    CGFloat _systemVersion;
    UIColor *preBarTintColor;
}

@end

@implementation BaseNavigationController

#pragma mark - Creating Navigation Controllers


- (id)init {
    self = [super initWithNavigationBarClass:[CRNavigationBar class] toolbarClass:nil];
    if(self) {
        
    }
    return self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController
{
//    BaseNavigationController* nvc = [super initWithNavigationBarClass:[CRNavigationBar class] toolbarClass:nil];
//    self.viewControllers = @[rootViewController];
    BaseNavigationController *nvc = [super initWithRootViewController:rootViewController];
    if (USE_SYSTEM_GESTURE) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    nvc.delegate = self;
//    if ([rootViewController isMemberOfClass:[CommonWebViewController class]])
//    {
//        self.navigationStyle = BaseNavigtionStyleBlack;
//    }
//    else {
//        self.navigationStyle = BaseNavigtionStyleWhite;
//    }
    
//    [self.navigationBar setBarStyle:UIBarStyleBlack];
    return nvc;
}

-(void)setNavigationStyle:(BaseNavigtionStyle)navigationStyle
{
    _navigationStyle = navigationStyle;
    switch (navigationStyle) {
        case BaseNavigtionStyleWhite:
        {
            [self.navigationBar setBarStyle:UIBarStyleDefault];
            [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0x333333ff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            [self.navigationBar lt_setBackgroundColor:[UIColor whiteColor]];
            self.navigationController.navigationBar.clipsToBounds = YES;
            [self.navigationBar setShadowImage:nil];
        }
            break;
        case BaseNavigtionStyleBlack:
        {
            [self.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [self.navigationBar setShadowImage:nil];
            [self.navigationBar lt_setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.95]];
//            [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:nil]];
            [self.navigationBar setShadowImage:[UIImage imageWithColor:nil]];
            [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0x333333ff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
            break;
        case BaseNavigtionStyleClear:
        {
            [self.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [self.navigationBar setShadowImage:[UIImage new]];
            [self.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
            [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0xffffffff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
            break;
        case BaseNavigtionStyleGradient:
        {
            [self.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [self.navigationBar setShadowImage:[UIImage new]];
            [self.navigationBar lt_setBackgroundColor: self.navigationBarColor];//[UIColor clearColor]];
            [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0xffffffff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
            break;
        default:
            break;
    }
}


     
 

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
 
    [super navigationController:navigationController didShowViewController:viewController animated:animated];
 
    if (navigationController.viewControllers.count == 1)
        self.currentShowVC = Nil;
    else
        self.currentShowVC = viewController;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {

    return nil;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if(self.viewControllers.count == 1) return NO;
        return (self.currentShowVC == self.topViewController);
    }
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}



- (void)commonInit
{
    _peddingBlocks = [NSMutableArray arrayWithCapacity:2];
    _peedingOperation = [NSMutableArray arrayWithCapacity:2];
    _systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
}



@end

