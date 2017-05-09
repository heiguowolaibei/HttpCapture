//
//  NSArray+SwitchMethods.m
//  weixindress
//
//  Created by liuyihao1216 on 16/6/24.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "Object+SwitchMethods.h"
#import "NSObjectEx.h"

@implementation NSArray (SwitchMethods)
- (BOOL)wq_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"NSArray wq_writeToFile getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToFile:path atomically:useAuxiliaryFile];
}

- (BOOL)wq_writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"NSArray wq_writeToURL getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToURL:url atomically:atomically];
}

@end

@implementation NSDictionary (SwitchMethods)

- (BOOL)wq_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"NSDictionary wq_writeToFile getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToFile:path atomically:useAuxiliaryFile];
}

- (BOOL)wq_writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"NSDictionary wq_writeToURL getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToURL:url atomically:atomically];
}

@end

@implementation NSFileManager (SwitchMethods)

- (BOOL)wq_createFileAtPath:(NSString *)path contents:(nullable NSData *)data attributes:(nullable NSDictionary<NSString *, id> *)attr
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_createFileAtPath getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_createFileAtPath:path contents:data attributes:attr];
}

@end


@implementation NSData (SwitchMethods)

- (BOOL)wq_writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
//    if ([NSThread isMainThread] == false)
//    NSLog(@"wq_writeToFile getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToFile:path options:writeOptionsMask error:errorPtr];
}

- (BOOL)wq_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
//    if ([NSThread isMainThread] == false)
//    NSLog(@"wq_writeToURL getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToURL:url options:writeOptionsMask error:errorPtr];
}

- (BOOL)wq_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
//    if ([NSThread isMainThread] == false)
//    NSLog(@"wq_writeToFile:atomically getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToFile:path atomically:useAuxiliaryFile];
}

- (BOOL)wq_writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
//    if ([NSThread isMainThread] == false)
//    NSLog(@"wq_writeToURL:atomically getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToURL:url atomically:atomically];
}

+ (nullable instancetype)wq_dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_dataWithContentsOfFile:options getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_dataWithContentsOfFile:path options:readOptionsMask error:errorPtr];
}

+ (nullable instancetype)wq_dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"dataWithContentsOfURL:options getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_dataWithContentsOfURL:url options:readOptionsMask error:errorPtr];
}

+ (nullable instancetype)wq_dataWithContentsOfFile:(NSString *)path
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"dataWithContentsOfFile getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_dataWithContentsOfFile:path];
}

+ (nullable instancetype)wq_dataWithContentsOfURL:(NSURL *)url
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_dataWithContentsOfURL getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_dataWithContentsOfURL:url];
}

@end


@implementation NSString (SwitchMethods)

- (BOOL)wq_writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_writeToURL:atomically:encoding:error getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToURL:url atomically:useAuxiliaryFile encoding:enc error:error];
}

- (BOOL)wq_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_writeToFile:atomically:encoding:error getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_writeToFile:path atomically:useAuxiliaryFile encoding:enc error:error];
}

@end


@implementation NSKeyedUnarchiver (SwitchMethods)

+ (nullable id)wq_unarchiveObjectWithFile:(NSString *)path
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_unarchiveObjectWithFile getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_unarchiveObjectWithFile:path];
}

- (void)wq_finishDecoding
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"finishDecoding getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_finishDecoding];
}

@end


@implementation NSKeyedArchiver (SwitchMethods)

+ (BOOL)wq_archiveRootObject:(id)rootObject toFile:(NSString *)path
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_archiveRootObject:toFile: getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_archiveRootObject:rootObject toFile:path];
}

- (void)wq_finishEncoding
{
//    if ([NSThread isMainThread] == false)
//        NSLog(@"wq_finishEncoding getCallMethod = %@",[self getBacktraceSymbols]);
    assert([NSThread isMainThread]);
    return [self wq_finishEncoding];
}

@end



































