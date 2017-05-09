//
//  AFURLConnectionOperation+Custom.h
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFURLConnectionOperation.h"

@interface AFURLConnectionOperation(Custom)

//上报用
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval connectTime;
@property (nonatomic, assign) NSTimeInterval endTime;

/**
 附加信息
 */
@property (nonatomic, strong) NSString * sextra;

/**
 附加信息2
 */
@property (nonatomic, strong) NSString * sextra2;

/*
 是否开启runloop defalutModel
 */
@property (assign, nonatomic) BOOL bOpenDefaultModel;


typedef void (^AFURLConnectionOperationProgressBlock)(NSUInteger bytes, long long totalBytes, long long totalBytesExpected);
typedef void (^AFURLConnectionOperationAuthenticationChallengeBlock)(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge);
typedef NSCachedURLResponse * (^AFURLConnectionOperationCacheResponseBlock)(NSURLConnection *connection, NSCachedURLResponse *cachedResponse);
typedef NSURLRequest * (^AFURLConnectionOperationRedirectResponseBlock)(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse);
typedef void (^QQURLConnectionOperatioHeaderResponseBlock)(NSURLConnection *connection, NSURLResponse *headerResponse);

@end
