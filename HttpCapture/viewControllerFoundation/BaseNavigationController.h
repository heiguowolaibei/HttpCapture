//
//  BaseNavigationController.h
//


#import <UIKit/UIKit.h>
#import "QQNavigationController.h"
#import "QQNavigationController+OperationQueue.h"

typedef NS_ENUM(NSInteger, BaseNavigtionStyle) {
    BaseNavigtionStyleWhite = 0,
    BaseNavigtionStyleBlack = 1,
    BaseNavigtionStyleClear = 2,
    BaseNavigtionStyleGradient = 3,
};



 


@interface BaseNavigationController : QQNavigationController<UIGestureRecognizerDelegate>

@property(nonatomic,weak) UIViewController* currentShowVC;
@property(nonatomic,assign) BaseNavigtionStyle navigationStyle;
@property(nonatomic,strong) UIColor *navigationBarColor;
@property(nonatomic,assign) BOOL isCustomTransition;
@property(nonatomic, assign, getter = isTransitionInProgress) BOOL transitionInProgress;

- (void)setTransitionInProgress:(BOOL)transitionInProgress;


@end
