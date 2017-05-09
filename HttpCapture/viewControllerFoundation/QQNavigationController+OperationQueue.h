//
//  QQNavigationController+OperationQueue.h
//  QQMSFContact
//
//  Created by leoymwang on 14-6-4.
//
//

#import "QQNavigationController.h"

//========================================================
//navigationcontroller operation queue
//========================================================

typedef NS_ENUM(NSInteger, QQNavigationControllerOperationType) {
    QQNavigationControllerOperationTypeNone,
    QQNavigationControllerOperationTypePushViewController,
    QQNavigationControllerOperationTypePopToRootViewController,
    QQNavigationControllerOperationTypePopToViewController,
    QQNavigationControllerOperationTypePopViewController,
    QQNavigationControllerOperationTypeSetViewControllers,
    QQNavigationControllerOperationTypePresentViewController
};


@interface QQNavigationControllerOperation : NSObject
@property (nonatomic, assign) QQNavigationControllerOperationType type;
@property (nonatomic, retain) id parameters;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, copy) NSString *parametersHash;
@property (nonatomic, copy) NSString *parametersClassName;

+ (id)operationWithType:(QQNavigationControllerOperationType)type parameters:(id)parameters animated:(BOOL)animated;
+ (id)operationWithType:(QQNavigationControllerOperationType)type parametersHash:(NSString *)hash parametersCLassName:(NSString *)className animated:(BOOL)animated;
+ (id)simpleOperationWithOperation:(QQNavigationControllerOperation *)oper;

@end


@interface QQNavigationController (OperationQueue)

@property (nonatomic, readonly, getter=operationQueue) NSMutableArray *operationQueue;

- (void)ex_viewDidLoad;
- (void)ex_dealloc;
- (void)ex_pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)ex_popToRootViewControllerAnimated:(BOOL)animated;
- (NSArray *)ex_popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)ex_popViewControllerAnimated:(BOOL)animated;

- (void)setViewControllers:(NSArray *)viewControllers;
- (void)ex_setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

- (void)runNextOperation;

- (void)willShowViewController:(UIViewController *)vc;
- (void)didShowViewController:(UIViewController *)vc;
- (void)newViewControllerDidAppear;
- (id)superPopViewControllerAnimated:(QQNavigationControllerOperation *)oper;

@end

 


