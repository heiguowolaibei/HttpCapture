//
//  NSString+HTML.m
//  MWFeedParser
//
//  Copyright (c) 2010 Michael Waterfall
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the
//     purpose of any concept relating to diary/journal keeping.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSString+Convert.h"
#import "HttpCapture-swift.h"
#import "UIDevice+hw.h"

@implementation NSString (Convert)

- (NSString *)getFileNameWithoutSuffix{
    NSString * filePath = (NSString *)self;
    NSURL * url = [NSURL fileURLWithPath:filePath];
    if (url.fileURL)
    {
        NSString* fullPath = [filePath stringByExpandingTildeInPath];
        NSURL* myFileURL = [NSURL fileURLWithPath:fullPath];
        NSString *lastComponent = [myFileURL lastPathComponent];
        NSString * fileExtension = [myFileURL pathExtension];
        NSString * fileName = [lastComponent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",fileExtension] withString:@""];
        return fileName;
    }
    
    return @"";
}

- (NSString *)getConvertUA
{
    NSString * schemename = [NSString stringWithFormat:@" jdhttpmonitor/%@",[[UIDevice currentDevice] shortVersion]];
    NSString * newUA = self;
    NSString * wxAppendString = [NSString stringWithFormat:@" MQQBrowser/6.2 TBS/036524 MicroMessenger/6.3.18.800 NetType/WIFI Language/zh_CN%@",schemename];
    NSString * qqAppendString = [NSString stringWithFormat:@" MQQBrowser/6.2 TBS/036524 TBS/025489 V1_AND_SQ_6.0.0_300_YYB_D QQ/6.0.0.2605 NetType/WIFI WebP/0.3.0 Pixel/1440%@",schemename];
    newUA = [newUA stringByReplacingOccurrencesOfString:wxAppendString withString:@""];
    newUA = [newUA stringByReplacingOccurrencesOfString:qqAppendString withString:@""];
    newUA = [newUA stringByReplacingOccurrencesOfString:schemename withString:@""];
    
    NSInteger platformID = [[HttpCaptureManager shareInstance] getPlatformID];
    if (platformID == 0 && [newUA rangeOfString:schemename].length == 0)
    {
        newUA = [newUA stringByAppendingString:schemename];
    }
    else if (platformID == 1 && [newUA rangeOfString:wxAppendString].length == 0)
    {
        newUA = [newUA stringByAppendingString:wxAppendString];
    }
    else if (platformID == 2 && [newUA rangeOfString:qqAppendString].length == 0)
    {
        newUA = [newUA stringByAppendingString:qqAppendString];
    }
    
    return newUA;
}


@end
