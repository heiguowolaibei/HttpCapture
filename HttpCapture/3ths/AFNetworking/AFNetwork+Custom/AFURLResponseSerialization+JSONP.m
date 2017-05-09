//
//  AFURLResponseSerialization+JSONP.m
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFURLResponseSerialization+JSONP.h"
#import "HttpCapture-Swift.h"

static NSError * AFErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

static BOOL AFErrorOrUnderlyingErrorHasCodeInDomain(NSError *error, NSInteger code, NSString *domain) {
    if ([error.domain isEqualToString:domain] && error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return AFErrorOrUnderlyingErrorHasCodeInDomain(error.userInfo[NSUnderlyingErrorKey], code, domain);
    }
    
    return NO;
}

static id AFJSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions) {
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)JSONObject count]];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:AFJSONObjectByRemovingKeysWithNullValues(value, readingOptions)];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [(NSDictionary *)JSONObject allKeys]) {
            id value = (NSDictionary *)JSONObject[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                mutableDictionary[key] = AFJSONObjectByRemovingKeysWithNullValues(value, readingOptions);
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return JSONObject;
}

@implementation AFHTTPResponseSerializer(JSONP)

-(void)setUseJSONP:(BOOL)useJSONP {
    objc_setAssociatedObject(self, @selector(useJSONP), [NSNumber numberWithBool:useJSONP], OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (useJSONP) {
        NSMutableSet *tempSet = [self.acceptableContentTypes mutableCopy];
        [tempSet addObject:@"text/html"];
        self.acceptableContentTypes = tempSet;
    }
}

-(BOOL)useJSONP {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

@implementation AFJSONResponseSerializer(JSONP)

//+(void)load {
//    SEL org = @selector(responseObjectForResponse:data:error:);
//    SEL swi = @selector(jd_responseObjectForResponse:data:error:);
//    jd_swizzleSelector([self class], org, swi);
//}

-(BOOL)skipValidate:(NSURLResponse *)response
{
    return true;
}



- (id) responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self skipValidate:response] && ![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || AFErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, AFURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
    // See https://github.com/rails/rails/issues/1742
    NSStringEncoding stringEncoding = self.stringEncoding;
    if (response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    
    id responseObject = nil;
    NSError *serializationError = nil;
    @autoreleasepool {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
        
        if(responseString == nil)
        {
            long en =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            responseString = [[NSString alloc] initWithData:data encoding:en];
        }
        
        if (responseString && ![responseString isEqualToString:@" "]) {
            // Workaround for a bug in NSJSONSerialization when Unicode character escape codes are used instead of the actual character
            // See http://stackoverflow.com/a/12843465/157142
            data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            
            if (data) {
                if ([data length] > 0) {
                    
                    NSData * da = [data exchangeObject];
                    
                    id obj = [self handleData:da];
                    
                    if ([obj isKindOfClass:[NSData class]]) {
                        da = (NSData *)obj;
                        if (self.useJSONP)
                        {
                            da = [NSString JSONPConvertToJSON:da];
                        }
                    }
                    else {
                        responseObject = obj;
                    }
                    if(responseObject == nil)
                    {
                        responseObject = [NSJSONSerialization JSONObjectWithData:da options:self.readingOptions error:&serializationError];
                    }
                    if (responseObject == nil)
                    {
                        NSString * r2 = [[[NSString alloc ]initWithData:da encoding:NSUTF8StringEncoding ] removeSomeForJSON];
                        if (r2 && ![r2 isEqualToString:@" "]) {
                            serializationError = nil;
                            responseObject = [NSJSONSerialization JSONObjectWithData:[r2 dataUsingEncoding:NSUTF8StringEncoding] options:self.readingOptions error:&serializationError];
                        }
                    }
                    if (responseObject == nil)
                    {
//                        [[WebMonitor sharedInstance] webMonitorJSONError:response.URL.absoluteString];
                    }
                } else {
                    return nil;
                }
            } else {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Data failed decoding as a UTF-8 string", @"AFNetworking", nil),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Could not decode string: %@", @"AFNetworking", nil), responseString]
                                           };
                
                serializationError = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
            }
        }
    }
    
    if (self.removesKeysWithNullValues && responseObject) {
        responseObject = AFJSONObjectByRemovingKeysWithNullValues(responseObject, self.readingOptions);
    }
    
    if (error) {
        *error = AFErrorWithUnderlyingError(serializationError, *error);
    }
    
    return responseObject;
}

- (id)handleData:(NSData *)data {
    return data;
}

@end
