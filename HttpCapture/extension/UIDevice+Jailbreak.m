//
//  UIDevice+Jailbreak.m
//  weixindress
//
//  Created by 杨帆 on 15/6/30.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

#import "UIDevice+Jailbreak.h"
#import <objc/runtime.h>

@implementation UIDevice (Jailbreak)


+ (NSNumber*)appSyncExistRe {
    NSObject *obj = objc_getAssociatedObject(self, @selector(appSyncExistRe));
    if (obj) {
        return ((NSNumber *)obj);
    }
    return  nil;
}

+ (void)saveAppSyncExistRe:(BOOL)value {
    objc_setAssociatedObject(self, @selector(appSyncExistRe), @(value), OBJC_ASSOCIATION_ASSIGN);
}


+ (BOOL) isAppSyncExist
{
    NSNumber* re = [self appSyncExistRe];
    if (re)
    {
        return re.boolValue;
    }
    
    
    BOOL isbash = NO;
    BOOL isappsync = NO;
    
    
    
    FILE *f = fopen("/bin/bash", "r");
    if (f != NULL)
    {
        //Device is jailbroken
        isbash = YES;
        fclose(f);
    }
    
    if (isbash)
    {
        f = fopen("/Library/MobileSubstrate/DynamicLibraries/AppSync.plist", "r");
        if (f != NULL)
        {
            isappsync = YES;
            fclose(f);
        }
        if (isappsync == NO)
        {
            NSError *err;
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/private/var/lib/dpkg/info" error:&err];
            
            for (int i = 0; i < files.count; i++)
            {
                NSString *fname = [files objectAtIndex:i];
                if ([fname rangeOfString:@"appsync" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    isappsync = YES;
                    break;
                }
            }
        }
        if (isappsync == NO)
        {
            NSError *err;
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/lib/dpkg/info" error:&err];
            
            for (int i = 0; i < files.count; i++)
            {
                NSString *fname = [files objectAtIndex:i];
                if ([fname rangeOfString:@"appsync" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    isappsync = YES;
                    break;
                }
            }
        }
    }
    [self saveAppSyncExistRe:(isappsync == YES)];
    return isappsync == YES;
}
@end
