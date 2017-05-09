//
//  DateFormatterManager.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/17.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "OCDHTTPWatcherURLProtocol.h"
#import "Defines.h"
#import "ASIHTTPRequest.h"
#import "NSObject+Custom.h"
#import "NSURLConnection+Custom.h"
#import "NSString+network.h"
#import "HttpCapture-swift.h"
#import "NSObject+Custom.h"
#import "NSArray+Custom.h"

#define kOCDMessageStorageRequestKey @"OCDMessageStorageRequestKey"

static int watchOrderID = 0;

//static NSOperationQueue * queue;

@interface OCDHTTPWatcherURLProtocol ()<NSURLSessionDelegate,NSURLSessionDataDelegate>
{
    NSURLResponse * _response;
    CFRunLoopRef runloop;
    CFStringRef runloopMode;
}

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, strong) NSURLSession *session;

@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) ASIHTTPRequest * asiRequest;

@property (nonatomic, strong) NSMutableURLRequest *sessionRequest;

@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, strong) NSURLRequest *redirectedRequest;

@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, strong) Entry *currentEntry;

@property (nonatomic, assign) int64_t byteToSent;

@property (nonatomic, assign) int64_t byteToReceive;

@end

@implementation OCDHTTPWatcherURLProtocol

@dynamic response;

+ (void)load {
    watchOrderID = 0;
}

//+ (NSOperationQueue *)queue{
//    return queue;
//}

+ (int)getOrderID{
    @synchronized (self) {
        return watchOrderID;
    }
}

+ (void)setOrderID:(int)idd{
    @synchronized (self) {
        watchOrderID = idd;
    }
}

- (NSURLResponse *)response
{
    return _response;
}

- (void )setResponse:(NSURLResponse *)response
{
    if (_response != response) {
        _response = response;
    }
    [self recordResponse];
}

- (NSURLSession *)session {
    if (!_session) {
        NSLog(@"初始化session＝%@",self.request);
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    
    return _session;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"request canInitWithRequest = %@,%@,%i",request.URL,[NSURLProtocol propertyForKey:@"OCDHTTPWatcher" inRequest:request],[NSThread isMainThread]);
    
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"])
    {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:@"OCDHTTPWatcher" inRequest:request] != nil) {
        return NO;
    }
    return YES;
}

+ (NSMutableURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    request = [[HttpCaptureManager shareInstance] hostedRequestWithRequest:request];
    NSMutableURLRequest *mutableReqeust = nil;
    NSObject * obj = [request mutableCopy];
    if ([obj isKindOfClass:[NSMutableURLRequest class]])
    {
        mutableReqeust = (NSMutableURLRequest *)obj;
    }
    else{
        mutableReqeust = [[NSMutableURLRequest alloc]initWithURL:request.URL];
    }
    mutableReqeust.allHTTPHeaderFields = request.allHTTPHeaderFields;
    mutableReqeust.HTTPMethod = request.HTTPMethod;
    mutableReqeust.HTTPBody = request.HTTPBody;
    mutableReqeust.HTTPBodyStream = request.HTTPBodyStream;
    mutableReqeust.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    mutableReqeust.HTTPShouldUsePipelining = request.HTTPShouldUsePipelining;
    
    NSString * newAgent = [[mutableReqeust valueForHTTPHeaderField:@"User-Agent"] getConvertUA];
    if (newAgent != nil)
    {
        [mutableReqeust setValue:newAgent forHTTPHeaderField:@"User-Agent"];
    }
    
    [NSURLProtocol setProperty:[NSString stringWithFormat:@"%ld", (long) [OCDHTTPWatcherURLProtocol getOrderID]]
                        forKey:@"OCDHTTPWatcher"
                     inRequest:mutableReqeust];
    [OCDHTTPWatcherURLProtocol setOrderID:[OCDHTTPWatcherURLProtocol getOrderID] + 1];
    
    return mutableReqeust;
}

- (void)startLoading {
    //MARK_yihao asi只用在protocol里。
    if (self.request.URL == nil)
    {
        return;
    }
    
    NSLog(@"request startLoading = %@,%i,%@,%@",self.request.URL,[NSThread isMainThread], [NSThread currentThread],[NSURLProtocol propertyForKey:@"OCDHTTPWatcher" inRequest:self.request]);
    
    self.sessionRequest = [[self class] canonicalRequestForRequest:self.request];
    [self addHeaderField];
    [self processBodyData];
    
    [self recordRequestStart:nil];
    
    [self.sessionRequest removeHttpHeaderField:@"stringEncoding"];
    [_sessionRequest removeHttpHeaderField:@"HTTPBody"];
    
    runloop = CFRunLoopGetCurrent();
    runloopMode = CFRunLoopCopyCurrentMode(runloop);
    
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
}

- (void)addHeaderField{
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.request.URL];
    if (cookies.count > 0) {
        [self.sessionRequest setValue:[cookies appendCookieNameValue] forHTTPHeaderField:@"Cookie"];
    }
}

- (void)processBodyData{
    NSData * bodydata = self.request.getHTTPBodyFromHeaderField;
    if (bodydata.length > 0 && self.request.HTTPBodyStream == nil) {
        _sessionRequest.HTTPBody = [bodydata mutableCopy];
    }
}

- (void)stopLoading
{
    NSLog(@"stopLoading response = %@,%@,%@",_response,[NSURLProtocol propertyForKey:@"OCDHTTPWatcher" inRequest:self.request],self.request);
    [self.dataTask cancel];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
     //直接验证服务器是否被认证（serverTrust），这种方式直接忽略证书验证，直接建立连接，但不能过滤其它URL连接，可以理解为一种折衷的处理方式，实际上并不安全，因此不推荐。
     SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
     return [[challenge sender] useCredential: [NSURLCredential credentialForTrust: serverTrust] forAuthenticationChallenge: challenge];
    
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust]) {
        do
        {
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            NSCAssert(serverTrust != nil, @"serverTrust is nil");
            if(nil == serverTrust)
                break; /* failed */
            /**
             *  导入多张CA证书（Certification Authority，支持SSL证书以及自签名的CA）
             */
            NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"cloudwin" ofType:@"cer"];//自签名证书
            NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
            
            NSString *cerPath2 = [[NSBundle mainBundle] pathForResource:@"apple" ofType:@"cer"];//SSL证书
            NSData * caCert2 = [NSData dataWithContentsOfFile:cerPath2];
            
            NSCAssert(caCert != nil, @"caCert is nil");
            if(nil == caCert)
                break; /* failed */
            
            NSCAssert(caCert2 != nil, @"caCert2 is nil");
            if (nil == caCert2) {
                break;
            }
            
            SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
            NSCAssert(caRef != nil, @"caRef is nil");
            if(nil == caRef)
                break; /* failed */
            
            SecCertificateRef caRef2 = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert2);
            NSCAssert(caRef2 != nil, @"caRef2 is nil");
            if(nil == caRef2)
                break; /* failed */
            
            NSArray *caArray = @[(__bridge id)(caRef),(__bridge id)(caRef2)];
            
            NSCAssert(caArray != nil, @"caArray is nil");
            if(nil == caArray)
                break; /* failed */
            
            OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
            NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
            if(!(errSecSuccess == status))
                break; /* failed */
            
            SecTrustResultType result = -1;
            status = SecTrustEvaluate(serverTrust, &result);
            if(!(errSecSuccess == status))
                break; /* failed */
            NSLog(@"stutas:%d",(int)status);
            NSLog(@"Result: %d", result);
            
            BOOL allowConnect = (result == kSecTrustResultUnspecified) || (result == kSecTrustResultProceed);
            if (allowConnect) {
                NSLog(@"success");
            }else {
                NSLog(@"error");
            }
            /* https://developer.apple.com/library/ios/technotes/tn2232/_index.html */
            /* https://developer.apple.com/library/mac/qa/qa1360/_index.html */
            /* kSecTrustResultUnspecified and kSecTrustResultProceed are success */
            if(! allowConnect)
            {
                break; /* failed */
            }
            
#if 0
            /* Treat kSecTrustResultConfirm and kSecTrustResultRecoverableTrustFailure as success */
            /*   since the user will likely tap-through to see the dancing bunnies */
            if(result == kSecTrustResultDeny || result == kSecTrustResultFatalTrustFailure || result == kSecTrustResultOtherError)
                break; /* failed to trust cert (good in this case) */
#endif
            
            // The only good exit point
            return [[challenge sender] useCredential: [NSURLCredential credentialForTrust: serverTrust]
                          forAuthenticationChallenge: challenge];
            
        } while(0);
    }
    
    // Bad dog
    return [[challenge sender] cancelAuthenticationChallenge: challenge];
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response != nil) {
        self.redirectedRequest = request;
        self.response = response;
        [self recordRequestFinish];
        self.currentEntry = nil;
        self.redirectedRequest = nil;
        [self recordRequestStart:request];
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.byteToSent = totalBytesExpectedToWrite;
    NSDate * date = [self.currentEntry getStartDate];
    
    CallBackModel * m = [[HttpCaptureManager shareInstance] queryModelForKey:self.request.URL.absoluteString];
    if (m != nil)
    {
        NSString * selector = m.callBack;
        [self performSelector:self.request.URL.absoluteString bytesSent:bytesWritten totalBytesSent:totalBytesWritten totalBytesExpectedToSend:totalBytesExpectedToWrite selector:selector target:[HttpCaptureManager shareInstance]];
    }
    
    if (date != nil && totalBytesWritten == totalBytesExpectedToWrite)
    {
        [self.currentEntry.timings setSendTime:date endSendDate:[NSDate date]];
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.data = [NSMutableData data];
    self.byteToReceive = response.expectedContentLength;

    self.response = response;
    NSDate * date = [self.currentEntry getStartDate];
    if (date != nil) {
        [self.currentEntry.timings setWaitTime:date endDate:[NSDate date]];
    }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    
    [self.data appendData:data];
    
    if (self.data.length > 0 && self.byteToReceive == self.data.length) {
        [self.currentEntry.timings setReceiveTime:[NSDate date]];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
    [self recordRequestFinish];
}

//url:String,bytesSent:Int,totalBytesSent:Int,totalBytesExpectedToSend:Int
- (void)performSelector:(NSString *)url bytesSent:(int64_t)byteSent totalBytesSent:(int64_t)totalBytes totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend selector:(NSString *)method target:(NSObject *)target
{
    if (![target respondsToSelector:NSSelectorFromString(method)])
    {
        return ;
    }
    NSString *string0 = [NSString stringWithString:url];
    NSString *string1 = [NSString stringWithFormat:@"%lli",byteSent];
    NSString *string2 = [NSString stringWithFormat:@"%lli",totalBytes];
    NSString *string3 = [NSString stringWithFormat:@"%lli",totalBytesExpectedToSend];
    NSMethodSignature *sig = [target methodSignatureForSelector:NSSelectorFromString(method)];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    [invocation setTarget:target];
       
    [invocation setSelector:NSSelectorFromString(method)];
    
    [invocation setArgument:&string0 atIndex:2];
    
    [invocation setArgument:&string1 atIndex:3];
    
    [invocation setArgument:&string2 atIndex:4];
    
    [invocation setArgument:&string3 atIndex:5];
    
    [invocation performSelector:@selector(invoke)];
}

- (void)recordRequestStart:(NSURLRequest *)request{
    if (self.currentEntry == nil) {
        _currentEntry = [Entry new];
        
        NSURLRequest * currentRes = request ? request : _sessionRequest;
        
        NSDate * date = [NSDate date];
        
        [_currentEntry setPageref:[[HttpCaptureManager shareInstance] getPageID:date]];
        [_currentEntry setURL:currentRes.URL];
        
        NSDictionary * parameters = [currentRes getParametersHeaderField];
        NSData * bodyData = [currentRes getHTTPBodyFromHeaderField];
        if (currentRes.HTTPBodyStream) {
            bodyData = [NSData new];
        }
        NSStringEncoding encode = [currentRes valueForHTTPHeaderField:@"stringEncoding"].integerValue;
        NSString * text = [[NSString alloc] initWithData:bodyData encoding:encode];
        PostData * postdata = [[PostData alloc]initWithMimeType:[currentRes.URL.absoluteString getMimeType] parameters:parameters text:text comment:@""];
        NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:currentRes.URL];
        Request * re = [[Request alloc]initWithRe:currentRes cookies:cookies postData:postdata headersSize:-1 bodySize:bodyData.length comment:@"" reID:[NSURLProtocol propertyForKey:@"OCDHTTPWatcher" inRequest:currentRes]];
        
        _currentEntry.request = re;
        
        [_currentEntry setEntryStartedDateTime:date];
    }
    else{
        NSLog(@"recordRequestStart not nil");
    }
}

- (void)recordResponse{
    NSHTTPURLResponse * res = (NSHTTPURLResponse *)self.response;
    if (res) {
        Content * content = [[Content alloc] initWithSize:self.data.length mimeType:res.MIMEType text:[self.data transferToString] encoding:res.textEncodingName comment:@"" data:self.data url:self.request.URL.absoluteString];
        NSArray * cookies = [NSHTTPCookie
                             cookiesWithResponseHeaderFields:[res allHeaderFields]
                             forURL:_response.URL];
        NSString * redirectString = self.redirectedRequest.URL.absoluteString.length > 0 ? self.redirectedRequest.URL.absoluteString : @"";
        Response * recordRes = [[Response alloc]initWithStatus:[res statusCode] statusText:@"" httpVersion:@"" cookies:cookies headers:[res allHeaderFields] content:content redirectURL:redirectString headersSize:-1 bodySize:self.data.length comment:@""];
        self.currentEntry.response = recordRes;
        
        if (self.request.HTTPBodyStream) {
            NSString * sHttpbodyStream = [self.request getHttpBodyStream];
            self.currentEntry.request.postData.text = sHttpbodyStream;
            self.currentEntry.request.bodySize = self.byteToSent;
        }
    }
}

- (void)recordRequestFinish{
    [self.currentEntry setEntryTime:[NSDate date]];
    self.currentEntry.response.bodySize = self.data.length;
    [self.currentEntry.response.content setData:self.data];
    self.currentEntry.response.content.text = [self.data transferToString];
    self.currentEntry.response.content.size = self.data.length;
    [[HttpCaptureManager shareInstance] appendRequestEntry:self.currentEntry];
}


@end
