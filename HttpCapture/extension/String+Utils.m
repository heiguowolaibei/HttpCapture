//
//  String+Utils.m
//  weixindress
//
//  Created by ECCSQ-lawrenceluo on 15/5/1.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "String+Utils.h"
#import "HttpCapture-swift.h"

@implementation NSString (Utils)


- (NSString*)stringByRemoveHTTPScheme
{
    if([self hasPrefix:@"http:"])
    {
        return [self substringFromIndex:5];
    }
    else if ([self hasPrefix:@"https:"])
    {
        return [self substringFromIndex:6];
    }
    return self;
}

- (NSString*)stringWithURLEncode
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    size_t sourceLen = strlen((const char *)source);
    for (size_t i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
    
}

- (NSString*)stringEscape
{

    NSString* output = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, nil, (CFStringRef)@"!*'();:@&=+$,%#[]", kCFStringEncodingUTF8));
    
    return output;
    
    
}

- (NSString*)stringUnEscape
{
    NSString* output = CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
    

    return output;
}

// 根据日期获取星座
+ (NSString *)getAstroWithMonth:(int)m day:(int)d{
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    }else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}

- (nullable id)objectFromJSONString{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil)
    {
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        data = [self dataUsingEncoding:encoding];
    }
    
    return [data objectFromJSONData];
}

//判断中英混合的的字符串长度
- (NSInteger)caculateStringLength
{
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    NSUInteger length = [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<length ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
}



@end





