//
//  ASIHTTPRequest+Custom.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/16.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "AFURLRequestSerialization.h"

@interface ASIHTTPRequest (Custom)

- (NSString *)OCDHTTPWatcher;

- (void)setOCDHTTPWatcher:(NSString *)ocdWatchID;

@end

@interface NSURLRequest (Custom)

- (BOOL)allowLoad;

- (void)setAllowLoad:(BOOL)allowLoad;

- (NSDictionary *)requestParameters;

- (void)setRequestParameters:(id)param;

- (id)wq_copy;

- (id)wq_mutableCopy;

- (NSData *)getHTTPBodyFromHeaderField;

- (NSDictionary *)getParametersHeaderField;

- (NSString *)getHttpBodyStream;

- (void)removeHttpHeaderField:(NSString *)key;

//- (BOOL)isRedirect;
//
//- (void)setIsRedirect:(BOOL)isRedirect;


@end

@interface NSURLSession (Custom)

- (NSString *)filePath;

- (void)setFilePath:(NSString *)filePath;

- (NSURLSessionUploadTask *)wq_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL;

- (NSURLSessionUploadTask *)wq_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;

@end

@interface NSObject (Custom)

- (nullable NSString *)getMimeType;


@end

@interface AFHTTPBodyPart(Custom)

- (NSMutableString *)bodyStreamText;

- (void)setBodyStreamText:(NSMutableString * )text;

- (void)appendBodyStream:(NSString * )text;

- (void)appendBodyStreamWithBuffer:(u_int8_t * )buffer length:(long)length;

@end

@interface AFHTTPRequestSerializer(Custom)

- (NSURLRequest *)wq_requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error;

@end

@interface AFJSONRequestSerializer(Custom)

- (NSURLRequest *)wq_requestBySerializingRequest:(NSURLRequest *)request
                                  withParameters:(id)parameters
                                           error:(NSError *__autoreleasing *)error;

@end


@interface AFPropertyListRequestSerializer(Custom)

- (NSURLRequest *)wq_requestBySerializingRequest:(NSURLRequest *)request
                                  withParameters:(id)parameters
                                           error:(NSError *__autoreleasing *)error;

@end



@interface NSMutableAttributedString(Custom)

- (BOOL)highlightString:(NSString *)string withColour:(UIColor *)color ;

- (NSRange)getFirstRange:(NSString *)string;

@end







