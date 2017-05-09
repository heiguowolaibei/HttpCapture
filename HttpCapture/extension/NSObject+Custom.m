//
//  ASIHTTPRequest+Custom.m
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/16.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "NSObject+Custom.h"
#import <objc/runtime.h>
#import "NSData+ImageContentType.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSObject+Json.h"

@implementation ASIHTTPRequest (Custom)


- (NSString *)OCDHTTPWatcher
{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj != nil && [obj isKindOfClass:[NSString class]])
    {
        return (NSString *)obj;
    }
    return @"";
}

- (void)setOCDHTTPWatcher:(NSString *)ocdWatchID
{
    objc_setAssociatedObject(self,@selector(OCDHTTPWatcher),ocdWatchID,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

@implementation NSURLRequest (Custom)

- (BOOL)allowLoad{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj != nil && [obj isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)obj boolValue];
    }
    return true;
}

- (void)setAllowLoad:(BOOL)allowLoad{
    objc_setAssociatedObject(self,@selector(allowLoad),@(allowLoad),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)requestParameters
{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)obj;
    }
    return [NSDictionary dictionary];
}

- (void)setRequestParameters:(NSDictionary *) param
{
    objc_setAssociatedObject(self,@selector(requestParameters),param,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)wq_copy
{
    id idd = [self wq_copy];
    [idd setRequestParameters:self.requestParameters];
    return idd;
}

- (id)wq_mutableCopy
{
    id idd = [self wq_mutableCopy];
    [idd setRequestParameters:self.requestParameters];
    return idd;
}

- (NSData *)getHTTPBodyFromHeaderField
{
    NSData * data = [NSData data];
    NSString * fieldValue = [self valueForHTTPHeaderField:@"HTTPBody"];
    NSStringEncoding encode = [self valueForHTTPHeaderField:@"stringEncoding"].integerValue;
    if (encode == 0) {
        encode = NSUTF8StringEncoding;
    }
    data = [fieldValue dataUsingEncoding:encode];
    
    return data;
}

- (void)removeHttpHeaderField:(NSString *)key
{
    NSString * value = [self valueForHTTPHeaderField:key];
    if (value.length > 0 && [self isKindOfClass:[NSMutableURLRequest class]]) {
        [(NSMutableURLRequest *)self setValue:nil forHTTPHeaderField:key];
    }
}

- (NSString *)getHttpBodyStream{
    NSMutableString * streamString = [NSMutableString string];
    
    NSArray * keys = [[self propertyListOfClass:NSClassFromString(@"AFMultipartBodyStream")] allKeys];
    if ([keys containsObject:@"HTTPBodyParts"])
    {
        id ar = (NSArray *)[self.HTTPBodyStream valueForKey:@"HTTPBodyParts"];
        if (ar)
        {
            for (id item in ar) {
                if ([item isKindOfClass:NSClassFromString(@"AFHTTPBodyPart")])
                {
                    NSString * value = (NSString *)[item valueForKey:@"bodyStreamText"];
                    if (value) {
                        [streamString appendString:value];
                    }
                }
            }
        }
    }
    
    return streamString;
}

- (NSDictionary *)getParametersHeaderField
{
    NSData * data = [NSData data];
    NSString * fieldValue = [self valueForHTTPHeaderField:@"parameters"];
    if (fieldValue != nil) {
        NSData * da = [[NSData alloc]initWithBase64EncodedString:fieldValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSDictionary * dic = nil;
        if (data != nil) {
            dic = [NSKeyedUnarchiver unarchiveObjectWithData:da];
        }
        return dic;
    }
   
    return [NSDictionary dictionary];
}

//- (BOOL)isRedirect{
//    id obj = objc_getAssociatedObject(self, _cmd);
//    if (obj != nil && [obj isKindOfClass:[NSNumber class]])
//    {
//        return [(NSNumber *)obj boolValue];
//    }
//    return false;
//}
//
//- (void)setIsRedirect:(BOOL)isRedirect{
//    objc_setAssociatedObject(self,@selector(isRedirect),@(isRedirect),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}


@end


@implementation NSURLSession (Custom)

- (NSString *)filePath{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj != nil && [obj isKindOfClass:[NSString class]])
    {
        return (NSString *)obj;
    }
    return @"";
}

- (void)setFilePath:(NSString *)filePath{
    objc_setAssociatedObject(self,@selector(filePath),filePath,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionUploadTask *)wq_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL
{
    [self setFilePath:fileURL.absoluteString];
    return [self wq_uploadTaskWithRequest:request fromFile:fileURL];
}

- (NSURLSessionUploadTask *)wq_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler
{
    [self setFilePath:fileURL.absoluteString];
    return [self wq_uploadTaskWithRequest:request fromFile:fileURL completionHandler:completionHandler];
}


@end

@implementation NSObject (Custom)

- (NSString *)getMimeType
{
    NSString * mime = @"";
    if ([self isKindOfClass:[UIImage class]]) {
        NSData * data = UIImageJPEGRepresentation((UIImage *)self, 1);
        NSString * s =[NSData sd_contentTypeForImageData:data];
        if (s != nil) {
            mime = s;
        }
    }
    else if ([self isKindOfClass:[NSString class]]){
        NSString * filePath = (NSString *)self;
        NSURL * url = [NSURL URLWithString:filePath];
        if (url.fileURL)
        {
            NSString* fullPath = [filePath stringByExpandingTildeInPath];
            NSURL* myFileURL = [NSURL fileURLWithPath:fullPath];
            NSString *fileExtension = [myFileURL pathExtension];
            NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
            NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
            if (contentType != nil) {
                mime = contentType;
            }
        }
    }
    return mime;
}


@end


@implementation AFHTTPBodyPart(Custom)

- (NSMutableString *)bodyStreamText
{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj != nil && [obj isKindOfClass:[NSMutableString class]])
    {
        return (NSMutableString *)obj;
    }
    
    NSMutableString * s = [NSMutableString string];
    [self setBodyStreamText:s];
    return s;
}

- (void)setBodyStreamText:(NSMutableString *)text
{
    objc_setAssociatedObject(self,@selector(bodyStreamText),text,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendBodyStream:(NSString *)text
{
    [[self bodyStreamText] appendString:text];
    [self setBodyStreamText:[self bodyStreamText]];
}

- (void)appendBodyStreamWithBuffer:(u_int8_t *)buffer length:(long)length;
{
    NSData * da = [NSData dataWithBytes:buffer length:length];
    NSString * s = [[NSString alloc]initWithData:da encoding:NSUTF8StringEncoding];
    if (s != nil) {
        [self appendBodyStream:s];
    }
    else{
        [self appendBodyStream:[da base64EncodedStringWithOptions:0]];
    }
}

@end


@implementation AFHTTPRequestSerializer(Custom)

- (NSURLRequest *)wq_requestBySerializingRequest:(NSURLRequest *)request
withParameters:(id)parameters
error:(NSError *__autoreleasing *)error
{
    NSURLRequest *newRequest = [self wq_requestBySerializingRequest:request withParameters:parameters error:error];
    NSData * da = newRequest.HTTPBody;
    if ([newRequest isKindOfClass:[NSMutableURLRequest class]])
    {
        NSMutableURLRequest * mutableRequest = (NSMutableURLRequest *)newRequest;
        if (da.length > 0)
        {
            NSString * sParam = [[NSString alloc]initWithData:da encoding:self.stringEncoding];
            [mutableRequest setValue:sParam forHTTPHeaderField:@"HTTPBody"];
            [mutableRequest setValue:[NSString stringWithFormat:@"%i",self.stringEncoding] forHTTPHeaderField:@"stringEncoding"];
        }
        
        NSData * paradata = [NSKeyedArchiver archivedDataWithRootObject:parameters];
        if (paradata != nil) {
            [mutableRequest setValue:[paradata base64EncodedStringWithOptions:0]  forHTTPHeaderField:@"parameters"];
            NSString * s = [mutableRequest valueForHTTPHeaderField:@"parameters"];
//            NSLog(@"s = %@",s);
//            [[NSData alloc]initWithBase64EncodedString:s options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
    }
    
    return newRequest;
}

@end

@implementation AFJSONRequestSerializer(Custom)

- (NSURLRequest *)wq_requestBySerializingRequest:(NSURLRequest *)request
                                  withParameters:(id)parameters
                                           error:(NSError *__autoreleasing *)error
{
    NSURLRequest *newRequest = [self wq_requestBySerializingRequest:request withParameters:parameters error:error];
    if (![self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        NSData * da = newRequest.HTTPBody;
        if (da.length > 0 && [newRequest isKindOfClass:[NSMutableURLRequest class]])
        {
            NSMutableURLRequest * mutableRequest = (NSMutableURLRequest *)newRequest;
            NSString * sParam = [[NSString alloc]initWithData:da encoding:self.stringEncoding];
            [mutableRequest setValue:sParam forHTTPHeaderField:@"HTTPBody"];
            [mutableRequest setValue:[NSString stringWithFormat:@"%i",self.stringEncoding] forHTTPHeaderField:@"stringEncoding"];
            
            NSData * paradata = [NSKeyedArchiver archivedDataWithRootObject:parameters];
            if (paradata != nil) {
                [mutableRequest setValue:[[NSString alloc]initWithData:paradata encoding:NSUTF8StringEncoding]  forHTTPHeaderField:@"parameters"];
            }
            
        }
    }
    
    return newRequest;
}

@end


@implementation AFPropertyListRequestSerializer(Custom)

- (NSURLRequest *)wq_requestBySerializingRequest:(NSURLRequest *)request
                                  withParameters:(id)parameters
                                           error:(NSError *__autoreleasing *)error
{
    NSURLRequest *newRequest = [self wq_requestBySerializingRequest:request withParameters:parameters error:error];
    if (![self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        NSData * da = newRequest.HTTPBody;
        if (da.length > 0 && [newRequest isKindOfClass:[NSMutableURLRequest class]])
        {
            NSMutableURLRequest * mutableRequest = (NSMutableURLRequest *)newRequest;
            NSString * sParam = [[NSString alloc]initWithData:da encoding:self.stringEncoding];
            [mutableRequest setValue:sParam forHTTPHeaderField:@"HTTPBody"];
            [mutableRequest setValue:[NSString stringWithFormat:@"%i",self.stringEncoding] forHTTPHeaderField:@"stringEncoding"];
            
            NSData * paradata = [NSKeyedArchiver archivedDataWithRootObject:parameters];
            if (paradata != nil) {
                [mutableRequest setValue:[[NSString alloc]initWithData:paradata encoding:NSUTF8StringEncoding]  forHTTPHeaderField:@"parameters"];
            }
        }
    }
    
    return newRequest;
}

@end


@implementation NSMutableAttributedString(Custom)

- (BOOL)highlightString:(NSString *)string withColour:(UIColor *)color {
    NSError *_error;
    NSRegularExpression *_regexp = [NSRegularExpression regularExpressionWithPattern:string options:NSRegularExpressionCaseInsensitive error:&_error];
    if (_error == nil) {
        [_regexp enumerateMatchesInString:self.string.lowercaseString options:NSMatchingReportProgress range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            if (result.numberOfRanges > 0) {
                for (int i = 0; i < result.numberOfRanges; i++) {
                    [self addAttribute:NSBackgroundColorAttributeName value:color range:[result rangeAtIndex:i]];
                }
            }
        }];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (NSRange)getFirstRange:(NSString *)string{
    NSError *_error;
    __block NSRange range = NSMakeRange(0, 0);
    NSRegularExpression *_regexp = [NSRegularExpression regularExpressionWithPattern:string options:NSRegularExpressionCaseInsensitive error:&_error];
    if (_error == nil) {
        [_regexp enumerateMatchesInString:self.string options:NSMatchingReportProgress range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
  
            if (result.numberOfRanges > 0 && range.length == 0) {
                range = [result rangeAtIndex:0];
            }
        }];
        
        return range;
    } else {
        return range;
    }
}

@end










