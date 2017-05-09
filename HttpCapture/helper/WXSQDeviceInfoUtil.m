//
//  WXSQDeviceInfoUtil.m
//  weixindress
//
//  Created by tianjie on 2/26/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

#import "WXSQDeviceInfoUtil.h"
#import "UICKeyChainStore.h"
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>

@interface WXSQDeviceInfoUtil ()
{
    NSString *_uuidForDevice;
}
@end

@implementation WXSQDeviceInfoUtil

NSString *const _uuidForDeviceKey = @"wxsq_uuidForDevice";

+ (WXSQDeviceInfoUtil *)sharedInstance
{
    static WXSQDeviceInfoUtil *instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if(self = [super init]) {
    }
    
    return self;
}

#pragma mark - Public Method

+ (NSString *)uuidForDevice
{
    
    NSString *uuid =  [[[self sharedInstance] uuidForDevice] copy];
    return uuid;
}

+ (NSString *)systemMachine
{
    return [[self sharedInstance] systemMachine];
}

#pragma mark - Private Method

- (NSString *)uuidForDevice
{
    NSString *uuidForDeviceInMemory = _uuidForDevice;
    
    if(_uuidForDevice == nil) {
        _uuidForDevice = [UICKeyChainStore stringForKey:_uuidForDeviceKey];
        
        if(_uuidForDevice == nil) {
            _uuidForDevice = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidForDeviceKey];
            if(_uuidForDevice == nil) {
                _uuidForDevice = [self uuid];
            }
        }
    }
    
    if(![uuidForDeviceInMemory isEqualToString:_uuidForDevice]) {
        [[NSUserDefaults standardUserDefaults] setObject:_uuidForDevice forKey:_uuidForDeviceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UICKeyChainStore setString:_uuidForDevice forKey:_uuidForDeviceKey];
    }
    
    return _uuidForDevice;
}

- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *uuidValue = (__bridge_transfer NSString *)uuidStringRef;
    uuidValue = [uuidValue lowercaseString];
    uuidValue = [uuidValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidValue;
}

- (NSString *)systemMachine
{
    return [self getSystemInfoWithName:"hw.machine"];
}

- (NSString *)getSystemInfoWithName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

@end
