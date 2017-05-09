// The MIT License (MIT)
//
// Copyright (c) 2016 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "UIViewController+NavigationBar.h"
#import "BaseNavigationController.h"
#import "CRNavigationBar.h"
#import <objc/runtime.h>
#import "UINavigationBar+Awesome.h"
#import "HttpCapture-Swift.h"
#import "UIImage+Crop.h"

void UIViewControllerNavigationBarSwizzle(Class cls, SEL originalSelector) {
    NSString *originalName = NSStringFromSelector(originalSelector);
    NSString *alternativeName = [NSString stringWithFormat:@"UIViewControllerNavigationBar_%@", originalName];

    SEL alternativeSelector = NSSelectorFromString(alternativeName);

    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(cls, alternativeSelector);

    class_addMethod(cls,
                    originalSelector,
                    class_getMethodImplementation(cls, originalSelector),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(cls,
                    alternativeSelector,
                    class_getMethodImplementation(cls, alternativeSelector),
                    method_getTypeEncoding(alternativeMethod));

    method_exchangeImplementations(class_getInstanceMethod(cls, originalSelector),
                                   class_getInstanceMethod(cls, alternativeSelector));
}


@interface UIViewController (_NavigationBar) <UINavigationBarDelegate>
@end

@implementation UIViewController (NavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIViewControllerNavigationBarSwizzle(self, @selector(navigationItem));
        UIViewControllerNavigationBarSwizzle(self, @selector(setTitle:));
        UIViewControllerNavigationBarSwizzle(self, @selector(viewWillAppear:));
        UIViewControllerNavigationBarSwizzle(self, @selector(viewDidAppear:));
        UIViewControllerNavigationBarSwizzle(self, @selector(viewDidLayoutSubviews));
//        UIViewControllerNavigationBarSwizzle(self, @selector(setEdgesForExtendedLayout:));
//        UIViewControllerNavigationBarSwizzle(self, @selector(setAutomaticallyAdjustsScrollViewInsets:));
    });
}


#pragma mark - Properties


-(void)refreshNavigationbar:(CRNavigationBar*)navigationBar forStyle:(BaseNavigtionStyle)navigationStyle
{
    
    switch (navigationStyle) {
        case BaseNavigtionStyleWhite:
        {
            
            [navigationBar setBarStyle:UIBarStyleDefault];
            [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0x333333ff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            [navigationBar lt_setBackgroundColor:[UIColor whiteColor]];
//            self.navigationController.navigationBar.clipsToBounds = YES;
            [navigationBar setShadowImage:nil];
        }
            break;
        case BaseNavigtionStyleBlack:
        {
            [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [navigationBar setShadowImage:nil];
            [navigationBar lt_setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.95]];
            [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:nil]];
            [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0x333333ff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
            break;
        case BaseNavigtionStyleClear:
        {
            [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [navigationBar setShadowImage:[UIImage new]];
            [navigationBar lt_setBackgroundColor:[UIColor clearColor]];
            [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0xffffffff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
            break;
        case BaseNavigtionStyleGradient:
        {
            [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [navigationBar setShadowImage:[UIImage new]];
            [self.navigationBar lt_setBackgroundColor: [UIColor clearColor]];//[UIColor clearColor]];
            [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor fromRGBA:0xffffffff],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
            break;
        default:
            break;
    }
}

//-(void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
//{
//    objc_setAssociatedObject(self, @selector(setHidesBottomBarWhenPushed), @(hidesBottomBarWhenPushed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//
//}

-(BOOL)getCustomHidesBottomBarWhenPushed
{
    NSNumber *n = objc_getAssociatedObject(self, @selector(setHidesBottomBarWhenPushed));
    return n.boolValue;
}

-(void)setNavigationStyle:(BaseNavigtionStyle)navigationStyle
{
    if([self.navigationController isKindOfClass:[BaseNavigationController class]])
    {
        ((BaseNavigationController*)self.navigationController).navigationStyle = navigationStyle;
    }
 
    objc_setAssociatedObject(self, @selector(navigationBarStyle), @(navigationStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self refreshNavigationbar:self.navigationBar forStyle:navigationStyle];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (UINavigationBar *)navigationBar {
    UINavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(navigationBar));
    if (!navigationBar) {
        navigationBar = [[CRNavigationBar alloc] init];
        [self refreshNavigationbar:navigationBar forStyle:self.navigationBarStyle];
        navigationBar.delegate = self;
        objc_setAssociatedObject(self, @selector(navigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return navigationBar;
}

-(BaseNavigtionStyle)navigationBarStyle{
    NSNumber *num = objc_getAssociatedObject(self, @selector(navigationBarStyle));
    return num.integerValue;
}



-(void)UIViewControllerNavigationBar_setEdgesForExtendedLayout:(UIRectEdge)edge
{
    
}

- (UINavigationItem *)UIViewControllerNavigationBar_navigationItem {
    if ([self isKindOfClass:UINavigationController.class]) {
        return self.UIViewControllerNavigationBar_navigationItem;
    }
    if (![self respondsToSelector:@selector(hasCustomNavigationBar)]) {
        return self.UIViewControllerNavigationBar_navigationItem;
    }
    
    if(!self.hasCustomNavigationBar)
    {
        return self.UIViewControllerNavigationBar_navigationItem;
    }
    
    SEL key = @selector(UIViewControllerNavigationBar_navigationItem);
    UINavigationItem *item = objc_getAssociatedObject(self, key);
    if (!item) {
        item = [[UINavigationItem alloc] init];
        objc_setAssociatedObject(self, key, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.navigationBar pushNavigationItem:item animated:NO];
    }
    return item;
}


/**
 UIViewController originally overwrites the value of `navigationItem.title` with the value of `title`. It doesn't work
 property because we have swizzled `navigationItem`. To make it available, swizzle the `setTitle:` method to assign
 the value manually.
 */
- (void)UIViewControllerNavigationBar_setTitle:(NSString *)title {
    [self UIViewControllerNavigationBar_setTitle:title];
    if ([self isKindOfClass:UINavigationController.class]) {
        return;
    }
    if (![self respondsToSelector:@selector(hasCustomNavigationBar)]) {
        return;
    }
    if (!self.hasCustomNavigationBar){
        return;
    }
    self.navigationItem.title = title;
}

- (BOOL)prefersNavigationBarHidden {
    NSString *className = NSStringFromClass(self.class);
    NSArray *externalClassNames = @[
        @"CKSMSComposeRemoteViewController",
        @"MFMailComposeRemoteViewController",
    ];
    return [externalClassNames containsObject:className];
}


#pragma mark - Updating navigation item

- (void)updateNavigationItem {
    if (![self respondsToSelector:@selector(hasCustomNavigationBar)]) {
        return;
    }
    if (!self.hasCustomNavigationBar) {
        return;
    }
//    self.navigationBar.items = @[];
//    if (self.navigationController.viewControllers.count > 1) {
//        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
//        UIViewController *viewController = self.navigationController.viewControllers[index - 1];
//        UINavigationItem *prevItem =  viewController.navigationItem ;
//        [self.navigationBar pushNavigationItem:prevItem animated:NO];
//    }
    
 
    self.navigationBar.items = @[];
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
}


#pragma mark - View life cycle

- (void)UIViewControllerNavigationBar_viewWillAppear:(BOOL)animated {
    [self UIViewControllerNavigationBar_viewWillAppear:animated];
    if ([self isKindOfClass:UINavigationController.class]) {
        return;
    }
    if([self isKindOfClass:[UIViewController class]])
    {
        if (![self respondsToSelector:@selector(hasCustomNavigationBar)]) {
            [self.navigationController setNavigationBarHidden:self.prefersNavigationBarHidden animated:animated];
            return;
        }
        [self.navigationController setNavigationBarHidden:self.hasCustomNavigationBar animated:animated];
        
        //    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        [self updateNavigationItem];
    }
}

- (void)UIViewControllerNavigationBar_viewDidAppear:(BOOL)animated {
    [self UIViewControllerNavigationBar_viewDidAppear:animated];
    if ([self isKindOfClass:UINavigationController.class]) {
        return;
    }
    if (![self respondsToSelector:@selector(hasCustomNavigationBar)]) {
        return;
    }
    if (!self.hasCustomNavigationBar) {
        return;
    }
    [self updateNavigationItem];
}

- (void)UIViewControllerNavigationBar_viewDidLayoutSubviews {
    [self UIViewControllerNavigationBar_viewDidLayoutSubviews];
    if ([self isKindOfClass:UINavigationController.class]) {
        return;
    }
    if (![self respondsToSelector:@selector(hasCustomNavigationBar)]) {
        return;
    }
    if (self.hasCustomNavigationBar) {
        if (CGRectIsEmpty(self.navigationBar.frame)) {
            self.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
        }
        [self.view addSubview:self.navigationBar];
    } else {
        [self.navigationBar removeFromSuperview];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        //fixbug:有tableview或collectionView时在iOS7上会崩溃
        [self.view layoutIfNeeded];
    }
 
//    if(self.edgesForExtendedLayout == UIRectEdgeNone)
//    {
//        if(self.navigationBar.hidden == true)
//        {
//            CGRect orFrame = self.view.frame;
//            CGFloat newY = 20;
//            self.view.frame = CGRectMake(orFrame.origin.x,newY, orFrame.size.width, orFrame.size.height + orFrame.origin.y - newY);
//        }
//        else
//        {
//            CGRect orFrame = self.view.frame;
//            CGFloat newY = 64;
//            self.view.frame = CGRectMake(orFrame.origin.x,newY, orFrame.size.width, orFrame.size.height + orFrame.origin.y - newY);
//        }
//    }
}



#pragma mark - Utils

- (id)deepCopy:(id)object {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:object]];
}


#pragma mark - UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

@end
