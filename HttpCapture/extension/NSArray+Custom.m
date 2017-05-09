//
//  NSArray+Custom.m
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/17.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "NSArray+Custom.h"

@implementation NSArray (Custom)

- (NSArray *)append:(id)obj{
    NSMutableArray * ar = [NSMutableArray arrayWithArray:self];
    [ar addObject:obj];
    return ar;
}

- (NSString *)appendCookieNameValue{
    NSMutableString * appendNameValue = [NSMutableString stringWithString:@""];
    for (int i = 0; i < self.count; i++) {
        NSHTTPCookie * cookie = (NSHTTPCookie *)[self objectAtIndex:i];
        if (cookie) {
            [appendNameValue appendString:[NSString stringWithFormat:@"%@=%@;",cookie.name,cookie.value]];
        }
    }
    if (appendNameValue.length > 0) {
        NSRange range = NSMakeRange(appendNameValue.length - 1, 1);
        [appendNameValue replaceCharactersInRange:range withString:@""];
    }
    return appendNameValue;
}

@end
