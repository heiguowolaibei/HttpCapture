
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wbuiltin-macro-redefined"
#define __FILE__ "QQNavigationController+OperationQueue"
#pragma clang diagnostic pop

//
//  QQNavigationController+OperationQueue.m
//  QQMSFContacta
//
//  Created by leoymwang on 14-6-4.
//
//
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#import "QQNavigationController+OperationQueue.h"


#import <objc/runtime.h>

 
#pragma mark -
#pragma mark QQNavigationControllerOperation

__weak static QQNavigationController *_topNavigationController;

@implementation QQNavigationControllerOperation
@synthesize type;
@synthesize parameters;
@synthesize animated;
@synthesize parametersClassName;
@synthesize parametersHash;

+ (id)operationWithType:(QQNavigationControllerOperationType)type parameters:(id)parameters animated:(BOOL)animated {
    QQNavigationControllerOperation *oper = [QQNavigationControllerOperation new];
    oper.type = type;
    oper.parameters = parameters;
    oper.animated = animated;
    oper.parametersClassName = parameters ? NSStringFromClass([parameters class]) : nil;
    oper.parametersHash = parameters ? [NSString stringWithFormat:@"%p",parameters] : nil;
    
    return oper;
}


+ (id)operationWithType:(QQNavigationControllerOperationType)type parametersHash:(NSString *)hash parametersCLassName:(NSString *)className animated:(BOOL)animated {
    QQNavigationControllerOperation *oper = [QQNavigationControllerOperation new];
    oper.type = type;
    oper.animated = animated;
    oper.parametersClassName = className;
    oper.parametersHash = hash;
    
    return oper;
}

+ (id)simpleOperationWithOperation:(QQNavigationControllerOperation *)oper {
    return [QQNavigationControllerOperation
            operationWithType: oper.type
            parametersHash: oper.parameters ? [NSString stringWithFormat:@"%p",oper.parameters] : nil
            parametersCLassName: oper.parameters ? NSStringFromClass([oper.parameters class]) : nil
            animated: oper.animated];
}

- (void)dealloc {
    self.parameters = nil;
    self.parametersHash = nil;
    self.parametersClassName = nil;
}

- (NSString *)description {
    NSArray *types = [NSArray arrayWithObjects:@"QQNavigationControllerOperationTypeNone",
                      @"QQNavigationControllerOperationTypePushViewController",
                      @"QQNavigationControllerOperationTypePopToRootViewController",
                      @"QQNavigationControllerOperationTypePopToViewController",
                      @"QQNavigationControllerOperationTypePopViewController",
                      @"QQNavigationControllerOperationTypeSetViewControllers",
                      @"QQNavigationControllerOperationTypePresentViewController",
                      nil];
    return [NSString stringWithFormat:@"QQNavigationControllerOperation --- type:%@, animated:%zd, parameters:%@, parametersHash:%@, parametersClassName:%@", [types objectAtIndex:self.type], self.animated, self.parameters, self.parametersHash, self.parametersClassName];
}

@end

#pragma mark -
#pragma mark category QQNavigationController(PROPERTY)

@interface QQNavigationController (PROPERTY)

@property (nonatomic, copy) NSString *previousTopViewControllerHash;
@property (nonatomic, retain) QQNavigationControllerOperation *previousOperation; //上一个操作
@property (nonatomic, assign) BOOL transitioning; //标识是否处于界面切换动画过程中
@property (nonatomic, assign) BOOL waiting; //在延迟执行开始到操作完成阶段该值为YES
@property (nonatomic, assign) BOOL inProgress; //在在延迟执行开始到新界面展现出来阶段该值为YES
@property (nonatomic, assign) BOOL didCallViewDidAppear; //标识是否已经调过新界面的ViewDidAppear函数，如果调用在didShowViewController中则不需要再次执行新界面展现后的处理逻辑
@end

@implementation QQNavigationController (PROPERTY)

@dynamic transitioning;
@dynamic waiting;
@dynamic previousTopViewControllerHash;
@dynamic previousOperation;
@dynamic didCallViewDidAppear;
@dynamic inProgress;

static char *kTransitioning;
static char *kWaiting;
static char *kPreviousTopViewControllerHash;
static char *kPreviousOperation;
static char *kDidCallViewDidAppear;
static char *kInProgress;

#pragma mark -
#pragma mark -
#pragma mark dynamic properties

- (void)setTransitioning:(BOOL)transitioning {
    objc_setAssociatedObject(self, &kTransitioning, [NSNumber numberWithBool:transitioning], OBJC_ASSOCIATION_RETAIN);
}

-(BOOL)transitioning {
    id previousTopViewControllerHash = self.previousTopViewControllerHash;
    id currentTopViewControllerHash = [NSString stringWithFormat:@"%p", self.topViewController];
    
    BOOL ret = previousTopViewControllerHash && ![previousTopViewControllerHash isEqualToString:currentTopViewControllerHash];
//    QLog_Info(MODULE_IMPB_UIFRAMEWORK, " is in transitioning:%zd", ret);
    return ret;
}

- (void)setWaiting:(BOOL)waiting {
    objc_setAssociatedObject(self, &kWaiting, [NSNumber numberWithBool:waiting], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)waiting {
    NSNumber *num = objc_getAssociatedObject(self, &kWaiting);
//    QLog_Info(MODULE_IMPB_UIFRAMEWORK, "is in waiting:%zd", num?[num boolValue]:0);
    if (num) return [num boolValue];
    return NO;
}


- (void)setInProgress:(BOOL)inProgress {
    objc_setAssociatedObject(self, kInProgress, [NSNumber numberWithBool:inProgress], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)inProgress {
    NSNumber *num = objc_getAssociatedObject(self, &kInProgress);
    return num ? [num boolValue] : NO;
}


- (void)setDidCallViewDidAppear:(BOOL)didCallViewDidAppear {
    objc_setAssociatedObject(self, &kDidCallViewDidAppear, [NSNumber numberWithBool:didCallViewDidAppear], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)didCallViewDidAppear {
    NSNumber *num = objc_getAssociatedObject(self, &kDidCallViewDidAppear);
    return num ? [num boolValue] : NO;
}

- (NSString *)previousTopViewControllerHash {
    return objc_getAssociatedObject(self, &kPreviousTopViewControllerHash);
}

- (void)setPreviousTopViewControllerHash:(NSString *)previousTopViewControllerHash {
    objc_setAssociatedObject(self, &kPreviousTopViewControllerHash, previousTopViewControllerHash, OBJC_ASSOCIATION_COPY);
}

- (void)setPreviousOperation:(QQNavigationControllerOperation *)previousOperation {
    objc_setAssociatedObject(self, &kPreviousOperation, previousOperation, OBJC_ASSOCIATION_RETAIN);
}

- (QQNavigationControllerOperation *)previousOperation {
    return objc_getAssociatedObject(self, &kPreviousOperation);
}

@end

#pragma mark -
#pragma mark -
#pragma mark category QQNavigationController(OperationQueue)

@implementation QQNavigationController (OperationQueue)
@dynamic operationQueue;
static char *kOperationQueue;

- (void)setOperationQueue:(NSMutableArray *)operationQueue {
    objc_setAssociatedObject(self, &kOperationQueue, operationQueue, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)operationQueue {
    return objc_getAssociatedObject(self, &kOperationQueue);
}

#pragma mark -
#pragma mark extend methods

- (void)ex_viewDidLoad {
    self.transitioning = NO;
    self.inProgress = NO;
    self.waiting = NO;
    [self setOperationQueue:[NSMutableArray array]];
    
 
}

- (void)ex_dealloc {
    self.operationQueue = nil;
    self.previousOperation = nil;
    self.previousTopViewControllerHash = nil;
}

- (void)newViewControllerDidAppear {
 
//        QLog_Info(MODULE_IMPB_UIFRAMEWORK, "-received ViewControllerDidAppear notification :%s", [[vc description] UTF8String]);
        self.navigationBar.userInteractionEnabled = YES;
        _topNavigationController = self;
        self.inProgress = NO;
        self.didCallViewDidAppear = YES;
        [self _performNextOperation];
  
}


 

- (void)didShowViewController:(UIViewController *)vc {
//    QLog_Info(MODULE_IMPB_UIFRAMEWORK, "-didShowViewController:%s", [[vc description] UTF8String]);
    self.navigationBar.userInteractionEnabled = YES;
    if (!self.didCallViewDidAppear) {
        self.inProgress = NO;
        [self _performNextOperation];
    }
}

- (void)_performNextOperation {
    @synchronized(self.operationQueue) {
        self.previousTopViewControllerHash = [NSString stringWithFormat:@"%p", self.topViewController];
        [self runNextOperation];
    }
}


- (void)ex_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isPanning) return;
    
    @synchronized(self.operationQueue) {
        QQNavigationControllerOperation *oper = [QQNavigationControllerOperation
                                                 operationWithType:QQNavigationControllerOperationTypePushViewController
                                                 parameters:viewController
                                                 animated:animated];
        if(  !self.waiting && [self runPushOperationDirectly:oper]) {
            return;
        }
        
        if (  self.transitioning || self.waiting || self.isPanning) {
            [self addOperation:oper];
        } else {
            [self runOperation:oper inQueue:NO];
        }
    }
}


- (BOOL)runPushOperationDirectly:(QQNavigationControllerOperation *)oper {
    if (self.operationQueue.count == 0 && self.previousOperation && self.previousOperation.animated == NO) {
        [self runOperation:oper inQueue:NO];
        return YES;
    }
    
    if (self.operationQueue.count) {
        BOOL hasAnimation = NO;
        for (QQNavigationControllerOperation *oper in self.operationQueue) {
            hasAnimation = hasAnimation || oper.animated;
        }
        if (!hasAnimation) {
            @synchronized(self.operationQueue) {
                [self addOperation:oper];
                int counter = 0;
                while ([self.operationQueue firstObject] != oper) {
                    [self runNextOperation];
                    
                    if (counter++ > self.operationQueue.count) {
                        if ([self.operationQueue containsObject:oper]) {
                            [self.operationQueue removeObject:oper];
                        }
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_runNextOperation) object:nil];
                        return NO;
                    }
                }
                [self.operationQueue removeObject:oper];
                [self runOperation:oper inQueue:NO];
            }
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)ex_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.isPanning) return nil;
    
    @synchronized(self.operationQueue) {
        QQNavigationControllerOperation *oper = [QQNavigationControllerOperation
                                                 operationWithType:QQNavigationControllerOperationTypePopToRootViewController
                                                 parameters:[self.viewControllers firstObject]
                                                 animated:animated];
        
        if (  self.transitioning || self.waiting || self.isPanning) {
            [self addOperation:oper];
            return nil;
        } else {
            return [self runOperation:oper inQueue:NO];
        }
    }
}

- (NSArray *)ex_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isPanning) return nil;
    
    @synchronized(self.operationQueue) {
        QQNavigationControllerOperation *oper = [QQNavigationControllerOperation
                                                 operationWithType:QQNavigationControllerOperationTypePopToViewController
                                                 parameters:viewController
                                                 animated:animated];
        
        if (  self.transitioning || self.waiting || self.isPanning) {
            [self addOperation:oper];
            return nil;
        } else {
            return [self runOperation:oper inQueue:NO];
        }
    }
}

- (UIViewController *)ex_popViewControllerAnimated:(BOOL)animated {
    @synchronized(self.operationQueue) {
        NSInteger count = self.viewControllers.count;
        QQNavigationControllerOperation *oper = [QQNavigationControllerOperation
                                                 operationWithType:QQNavigationControllerOperationTypePopViewController
                                                 parameters:count > 2 ? [self.viewControllers objectAtIndex:(count-2)] : [self.viewControllers firstObject]
                                                 animated:animated];
        if(self.isPanning)
        {
              return [self runOperation:oper inQueue:NO];
        }
        else
        {
            if (  self.transitioning || self.waiting  ) {
                [self addOperation:oper];
                return nil;
            } else {
                return [self runOperation:oper inQueue:NO];
            }
        }

    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (void)ex_setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    if (self.isPanning) return;
    
    @synchronized(self.operationQueue) {
        QQNavigationControllerOperation *oper = [QQNavigationControllerOperation
                                                 operationWithType:QQNavigationControllerOperationTypeSetViewControllers
                                                 parameters:viewControllers
                                                 animated:animated];
        if (  self.transitioning || self.waiting || self.isPanning) {
            [self addOperation:oper];
        } else {
            [self runOperation:oper inQueue:NO];
        }
    }
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
 
    [super presentModalViewController:modalViewController animated:animated];
}


- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
 
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}


#pragma mark -
#pragma mark operation queue


- (void)addOperation:(QQNavigationControllerOperation *)oper {
//    if (![self isDuplicateOperation:oper]) {
        [self.operationQueue addObject:oper];
//      }
}


- (void)runNextOperation {
    if (self.operationQueue.count > 0) {
        
        // 如果要popto的vc已经不再stack中，则删除该操作并运行下一个操作
        QQNavigationControllerOperation *oper = [self.operationQueue firstObject];
        if (oper.type == QQNavigationControllerOperationTypePopToViewController
            && ![self.viewControllers containsObject:oper.parameters]) {
 
                [self.operationQueue removeObject:oper];
                [self runNextOperation];
        }
 
        self.waiting = YES;
        self.inProgress = YES;
        double delay = [self delayTime];
        if (!delay) {
            [self performSelectorOnMainThread:@selector(_runNextOperation) withObject:nil waitUntilDone:YES];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_runNextOperation) object:nil];
            [self performSelector:@selector(_runNextOperation) withObject:nil afterDelay:delay];
        }
    }
}

- (void)_runNextOperation {
    if (self.isPanning)
    {
        self.waiting = NO;
        return;
    }
    @synchronized(self.operationQueue) {
        if (self.operationQueue.count > 0) {
            QQNavigationControllerOperation *oper = [self.operationQueue objectAtIndex:0];
            [self.operationQueue removeObjectAtIndex:0];
            [self runOperation:oper inQueue:YES];
        }
          self.waiting = NO;
    }
}

- (id)runOperation:(QQNavigationControllerOperation *)oper inQueue:(BOOL)inQueue {
    self.waiting = YES;
    self.inProgress = YES;
    self.didCallViewDidAppear = NO;
    
    id ret = nil;
    char *flag = inQueue ? "in queue" : "directly";
    self.previousTopViewControllerHash = [NSString stringWithFormat:@"%p", self.topViewController];
    self.previousOperation = [QQNavigationControllerOperation simpleOperationWithOperation:oper];
    switch (oper.type) {
        case QQNavigationControllerOperationTypePopToRootViewController: {
            ret = [self superPopToRootViewControllerAnimated:oper];
            break;
		}
            
        case QQNavigationControllerOperationTypePopToViewController: {
            ret = [self superPopToViewController:oper];
            break;
		}
            
        case QQNavigationControllerOperationTypePopViewController: {
            ret = [self superPopViewControllerAnimated:oper];
            break;
		}
            
        case QQNavigationControllerOperationTypePushViewController: {
            [self superPushViewController:oper];
            break;
		}
            
        case QQNavigationControllerOperationTypeSetViewControllers: {
            [self superSetViewControllers:oper];
            break;
		}
            
        default:
            break;
    }
    
    self.waiting = NO;
    return ret;
}

// 判断当前oper是否属于重复操作
- (BOOL)isDuplicateOperation:(QQNavigationControllerOperation *)oper {
    QQNavigationControllerOperation *lastOper = nil;
    if (self.operationQueue.count > 0) { // 如果操作队列中还有操作未执行完，lastoper则为队列中最后一个操作
        lastOper = (QQNavigationControllerOperation *)[self.operationQueue lastObject];
    } else { // 如果操作队列为空，lastoper则为上次操作
        lastOper = self.previousOperation;
    }
    
    if (lastOper) {
        // 前后两次都是PopToRootViewController操作，认为是重复的
        if (oper.type == lastOper.type && oper.type == QQNavigationControllerOperationTypePopToRootViewController) {
            return YES;
        }
        
        // 前后两次都是push，且push的是相同类型的vc, 认为是重复的
        if (oper.type == lastOper.type && oper.type == QQNavigationControllerOperationTypePushViewController) {
            if ([oper.parametersClassName isEqualToString:[lastOper parametersClassName]]) {
                return YES;
            }
        }
        
        // 当前操作为PushViewController， 且队列中已经存在push到同一个vc的操作，认为是重复的
        if (oper.type == QQNavigationControllerOperationTypePushViewController) {
            for (QQNavigationControllerOperation *o in self.operationQueue) {
                if (o.type == QQNavigationControllerOperationTypePushViewController && o.parametersHash == oper.parametersHash) {
                    return YES;
                }
            }
        }
        
        // 前后两次都是present，且present的是相同类型的vc, 认为是重复的
        if (oper.type == lastOper.type && oper.type == QQNavigationControllerOperationTypePresentViewController
            && [oper.parametersClassName isEqualToString:lastOper.parametersClassName]) {
            return YES;
        }
        
        // 前后两次都是SetViewControllers， 且set的vcs都是相同的，认为是重复的
        if (oper.type == lastOper.type && oper.type == QQNavigationControllerOperationTypeSetViewControllers
            && oper.parametersHash == lastOper.parametersHash) {
            return YES;
        }
        
        // 前后两次都是pop操作，且popto的vc相同，则认为是重复的
        if ((oper.type == QQNavigationControllerOperationTypePopToRootViewController
             || oper.type == QQNavigationControllerOperationTypePopToViewController
             || oper.type == QQNavigationControllerOperationTypePopViewController)
            && (lastOper.type == QQNavigationControllerOperationTypePopToRootViewController
                || lastOper.type == QQNavigationControllerOperationTypePopToViewController
                || lastOper.type == QQNavigationControllerOperationTypePopViewController)
            && lastOper.parametersHash == oper.parametersHash) {
            return YES;
        }
        
        // 如果上次是poptorootviewcontroller或者stack中只有一个vc， 本次为pop操作，则认为是重复的
        if ((oper.type == QQNavigationControllerOperationTypePopToRootViewController
             || oper.type == QQNavigationControllerOperationTypePopToViewController
             || oper.type == QQNavigationControllerOperationTypePopViewController)
            && (lastOper.type == QQNavigationControllerOperationTypePopToRootViewController
                || self.viewControllers.count == 1)) {
            return YES;
        }
    }
    
    return NO;
}

- (float)delayTime {
    float time = 0.5f;
    if (self.operationQueue.count > 0) {
        QQNavigationControllerOperation *curOper = (QQNavigationControllerOperation *)[self.operationQueue firstObject];
        
        //前后两次操作都没有动画，可以立即执行
        if (curOper.animated == NO
            && self.previousOperation.animated == NO) {
            time = 0;
        }
    }
    
//    QLog_Info(MODULE_IMPB_UIFRAMEWORK, "run next operation delay %f seconds", time);
    return time;
}


#pragma mark -
#pragma mark super class operations

- (id)superPopToRootViewControllerAnimated:(QQNavigationControllerOperation *)oper {
    [self hideActionSheetOrAlertView];
 
    
    if (self.viewControllers.count == 1) {
        [self navigationController:self didShowViewController:self.viewControllers.firstObject animated:oper.animated];
        return nil;
    }
    
    self.navigationBar.userInteractionEnabled = NO;
    self.navigationBarHidden = NO;
    id ret = [super popToRootViewControllerAnimated:oper.animated];
    [self processWhenNavigationControllerInVisible];
    return ret;
}

- (id)superPopToViewController:(QQNavigationControllerOperation *)oper {
    [self hideActionSheetOrAlertView];
    NSUInteger showingControllerIndex = [self.viewControllers indexOfObject:oper.parameters];
    NSInteger popedControllerCount = self.viewControllers.count -1 - showingControllerIndex;
    if (popedControllerCount > 0) {
        [self updateOrientationSupportFromViewController:oper.parameters];
    }
    
    if (oper.parameters == self.viewControllers.lastObject
        || ![self.viewControllers containsObject:oper.parameters]) {
        if ( ![self.viewControllers containsObject:oper.parameters]) {
                   }
        [self navigationController:self didShowViewController:oper.parameters animated:oper.animated];
        return nil;
    }
    
    self.navigationBar.userInteractionEnabled = NO;
    id ret = [super popToViewController:oper.parameters animated:oper.animated];
    [self processWhenNavigationControllerInVisible];
    return ret;
}

- (id)superPopViewControllerAnimated:(QQNavigationControllerOperation *)oper {
    [self hideActionSheetOrAlertView];
    NSUInteger controllerCount = self.viewControllers.count;
    if (controllerCount > 1) {
//        [self removeLastViewTagAndReportIfNeed];
        [self updateOrientationSupportFromViewController:[[self viewControllers] objectAtIndex:controllerCount - 2]];
 
    }
    
    self.didCallViewDidAppear = NO;
    if (self.viewControllers.count == 1) {
        [self navigationController:self didShowViewController:oper.parameters animated:oper.animated];
        return nil;
    }
    
    self.navigationBar.userInteractionEnabled = NO;
    id ret = [super popViewControllerAnimated:oper.animated];
    [self processWhenNavigationControllerInVisible];
    return ret;
}

- (void)superPushViewController:(QQNavigationControllerOperation *)oper {
    self.navigationBar.userInteractionEnabled = NO;
    
    _gestureRecognizer.enabled = NO;
    [self hideActionSheetOrAlertView];
    
    [super pushViewController:oper.parameters animated:oper.animated];
//    [self pushViewTagForController:oper.parameters];
    [self processWhenNavigationControllerInVisible];
}

- (void)superSetViewControllers:(QQNavigationControllerOperation *)oper {
//jasonchqian
//影响范围过大，调整到下面的if条件中。leoymwang已经cr
//    [self hideActionSheetOrAlertView];
    
    //如果要set的viewcontroller与当前的viewcontroller一致，无需重复操作
    if ([(NSArray *)oper.parameters count] == self.viewControllers.count) {
        NSMutableString *currentViewControllersHash = [NSMutableString string];
        NSMutableString *futureureViewControllersHash = [NSMutableString string];
        for (UIViewController *vc in self.viewControllers) {
            [currentViewControllersHash appendFormat:@"%p", vc];
        }
        for (UIViewController *vc in oper.parameters) {
            [futureureViewControllersHash appendFormat:@"%p", vc];
        }
        if ([futureureViewControllersHash isEqualToString:currentViewControllersHash]) {
            [self navigationController:self
                 didShowViewController:[(NSArray *)oper.parameters lastObject]
                              animated:oper.animated];
            return;
        }
    }
    
    //如果当前的topviewcontroller等于新的topviewcontroller，viewdidappear将不会被调用，所以不能设置userInteractionEnabled=NO
    if (self.viewControllers.lastObject != [(NSArray *)oper.parameters lastObject]) {
        self.navigationBar.userInteractionEnabled = NO;
        [self hideActionSheetOrAlertView];//jasonchqian，调整到if中，避免topViewController正常展示模态界面时，被dismiss掉。
    }

    [super setViewControllers:oper.parameters animated:oper.animated];
    [self processWhenNavigationControllerInVisible];
}

- (void)processWhenNavigationControllerInVisible {
    if (!self.isViewLoaded || !self.view.window) {
        [self navigationController:self didShowViewController:self.topViewController animated:NO];
    }
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

@end


//========================================================
//navigationbar operation queue
//========================================================
 



