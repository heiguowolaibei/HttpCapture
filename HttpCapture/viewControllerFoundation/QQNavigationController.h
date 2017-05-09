//
//  QQNavigationController.h
//  QQMSFContact
//
//  这个东西只是用来解决窗口压战时突然又被弹窗而导致的crash
//
//  Created by Yang Jin on 12-3-18.
//  Copyright 2012 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QQNavigationController : UINavigationController<UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
	// 暂时只处理这2种情况
	BOOL _isPopViewController;
	BOOL _isPopToRootViewController;
    BOOL _isSupportRightDragToGoBack;
 
    CGFloat _popGuestureRespondWidth;
    NSMutableArray *_controllersToPop;
    NSArray *_rightBarButtonItems;
    
    @public
    UIPanGestureRecognizer* _gestureRecognizer;
}

@property (nonatomic, assign) BOOL isSupportRightDragToGoBack; // 是否加上随动返回的手势，默认=NO不支持
 
@property (nonatomic, assign) BOOL isTransitioning;
@property (nonatomic, assign,readonly) BOOL isPanning; // 手势pop时，判断是否处于右滑动作中
@property (nonatomic, assign) CGFloat popGuestureRespondWidth; //右滑返回手势的响应宽度，默认值为屏幕宽度
@property (nonatomic, assign, readonly, getter=isAnimating) BOOL isAnimating;

+ (instancetype)newWithRootViewController:(UIViewController *)rootViewController;

- (void)stopGesture;
- (void)updateGestureEnability:(BOOL)enabled;

- (UIViewController*)findViewContrlloer:(NSString*)name;
- (void)hideActionSheetOrAlertView;
- (void)updateOrientationSupportFromViewController:(UIViewController*)viewController;
 


//- (BOOL)isPopingViewController;
@end

//@interface QQSimpleNavigationController : UINavigationController
//
//@end


@protocol QQNavigationControllerEventDelegate <NSObject>

- (void)qqNavigationControllerDidPopViewController;

@end