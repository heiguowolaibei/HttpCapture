//
//  af_MethodSwizzleClass.h
//  weixindress
//
//  Created by 杜永超 on 16/2/18.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static inline void jd_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline BOOL jd_addMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}
