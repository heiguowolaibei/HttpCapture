//
//  NSObjectEx.h
//  QQMSFContact
//
//  Created by Yang Jin on 12-10-31.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

//
@interface NSObject (MethodSwizzlingCategory)

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel;
+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel;

// 转换所有类的方法
+ (void)switchAllMethod;
 
+ (void)switchScrollViewMethod;

// 获取当前设备可用内存(单位：MB）
- (double)availableMemory;
// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory;
//获取调用的堆栈
- (NSArray *)getBacktraceSymbols;

- (void)delayTime:(NSTimeInterval)time block:(void (^)(void))block;

@end

