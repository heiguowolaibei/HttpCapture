//
//  NSObjectEx.m
//  QQMSFContact
//
//  Created by Yang Jin on 12-10-31.
//
//

#import "NSObjectEx.h"
#import "UIView+SwizzleMethod.h"
#import "UIScrollView+SwizzleMethod.h"
#import "HttpCapture-Swift.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>

@interface _WebSelecterSwizzling : NSObject




@end

@implementation _WebSelecterSwizzling



static inline void af_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline BOOL af_addMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}

- (void)apickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
   
    NSInteger num = [pickerView numberOfRowsInComponent:component];
    if (row < num)
    {
        [self apickerView:pickerView didSelectRow:row inComponent:component];
    }
}

+(void)change
{
    Class d = NSClassFromString(@"UIWebSelectSinglePicker");
    Method afResumeMethod = class_getInstanceMethod(self, @selector(apickerView:didSelectRow:inComponent:));
    
    if (af_addMethod(d, @selector(apickerView:didSelectRow:inComponent:), afResumeMethod)) {
        af_swizzleSelector(d, @selector(pickerView:didSelectRow:inComponent:), @selector(apickerView:didSelectRow:inComponent:));
    }
}

@end


@implementation NSObject (MethodSwizzlingCategory)

- (void)WXDealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self WXDealloc];
}

- (NSArray *)getBacktraceSymbols{
    void * callstack[128];
    int frames = backtrace(callstack,128);
    
    char ** strs = backtrace_symbols(callstack,frames);
    int i ;
    NSMutableArray * backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < 4; i++) {
        if (strs[i] != nil)
        {
            [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
        }
    }
    free(strs);
    return backtrace;
}

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel
{
    Method originMethod = class_getInstanceMethod(self, origSel);
    Method newMethod = class_getInstanceMethod(self, altSel);
    
    

    if (originMethod && newMethod) {
       
        if (class_addMethod(self, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(self, altSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        } else {
            method_exchangeImplementations(originMethod, newMethod);
        }
        return YES;
    }
    return NO;
}

+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel
{
    Class c = object_getClass((id)self);
    return [c swizzleMethod:origSel withMethod:altSel];
}

+ (void)switchScrollViewMethod{
    [UIScrollView swizzleMethod:@selector(WXSetScrollsToTop:) withMethod:@selector(setScrollsToTop:)];
}

+ (void)mayNeedAllMethod
{
     [_WebSelecterSwizzling  change];
}

// 这个方法是把所有替换所有类的方法
+ (void)switchAllMethod
{
    [self mayNeedAllMethod];
    
    
//    [UIView swizzleMethod:@selector(addWXSubView:) withMethod:@selector(addSubview:)];
//    [UIView swizzleMethod:@selector(WXSetBounds:) withMethod:@selector(setBounds:)];
//    [UIView swizzleMethod:@selector(WXSetFrame:) withMethod:@selector(setFrame:)];
    
//    if (DEBUG)
//    {
//        [UIView swizzleMethod:@selector(setNeedsDisplay) withMethod:@selector(my_setNeedsDisplay)];
//        [UIView swizzleMethod:@selector(setNeedsLayout) withMethod:@selector(my_setNeedsLayout)];
//    }
    
//    [NSURLRequest swizzleMethod:@selector(copy) withMethod:@selector(wq_copy)];
//    [NSURLRequest swizzleMethod:@selector(mutableCopy) withMethod:@selector(wq_mutableCopy)];
    
    [AFHTTPRequestSerializer swizzleMethod:@selector(requestBySerializingRequest:withParameters:error:) withMethod:@selector(wq_requestBySerializingRequest:withParameters:error:)];
    [AFJSONRequestSerializer swizzleMethod:@selector(requestBySerializingRequest:withParameters:error:) withMethod:@selector(wq_requestBySerializingRequest:withParameters:error:)];
    [AFPropertyListRequestSerializer swizzleMethod:@selector(requestBySerializingRequest:withParameters:error:) withMethod:@selector(wq_requestBySerializingRequest:withParameters:error:)];
    
//    [UIAlertView swizzleMethod:@selector(show) withMethod:@selector(switchShow)];
    
    
  //    [UIControl swizzleMethod:@selector(addTarget:action:forControlEvents:) withMethod:@selector(addWeakTarget:action:forControlEvents:)];
//    [UINavigationItem swizzleMethod:@selector(QQSetLeftBarButtonItem:) withMethod:@selector(setLeftBarButtonItem:)];
//    [UINavigationItem swizzleMethod:@selector(QQSetRightBarButtonItem:) withMethod:@selector(setRightBarButtonItem:)];
//    [UINavigationItem swizzleMethod:@selector(QQGetLeftBarButtonItem) withMethod:@selector(leftBarButtonItem)];
//    [UINavigationItem swizzleMethod:@selector(QQGetRightBarButtonItem) withMethod:@selector(rightBarButtonItem)];
}


// 获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

- (void)delayTime:(NSTimeInterval)time block:(void (^)(void))block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

@end
