//
//  JsonParser.m
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/29.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "JsonParser.h"
#import "HttpCapture-swift.h"


typedef id(^ParseBlock)(id);

static JSContext * context;

@interface JsonParser ()
{
    
}


@end

@implementation JsonParser

+ (NSString *)getSuffixPattern{
    return @"\\);?$|\\);?\\s*\\}$|\\)\\s*;?\\}\\s*\\w+\\s*\\(\\w*\\)\\s*\\{?[^£]*\\}?$";
}

+ (id)jsonpParse:(NSData *)data{
    if (context == nil) {
        context = [[JSContext alloc]initWithVirtualMachine:[JSVirtualMachine new]];
        ParseBlock a = ^(id obj) {
            return obj;
        };
        [context setObject:a forKeyedSubscript:@"parse"];
    }
    
    NSString* dataStr = [data transferToString];
    dataStr = [dataStr stringByConvertingHTMLToPlainText];
    
    NSRegularExpression * preRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\w*\\s*\\{?\\s*\\w*\\s*\\(" options:NSRegularExpressionCaseInsensitive error:nil];
    
    if (preRegex && dataStr) {
        dataStr = [preRegex stringByReplacingMatchesInString:dataStr options:NSMatchingReportProgress range:NSMakeRange(0, dataStr.length) withTemplate:@""];
        
        NSRegularExpression * sufRegex = [NSRegularExpression regularExpressionWithPattern:[self getSuffixPattern] options:NSRegularExpressionCaseInsensitive error:nil];
        if (sufRegex) {
            dataStr = [sufRegex stringByReplacingMatchesInString:dataStr options:NSMatchingReportProgress range:NSMakeRange(0, dataStr.length) withTemplate:@""];
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"\\x" withString:@"\\u00"];
        }
    }
    
    NSMutableString * mutableString = [NSMutableString stringWithFormat:@"parse(%@)",dataStr];
    JSValue * value = [context evaluateScript:mutableString];
    
    return [value toObject];
}

@end
