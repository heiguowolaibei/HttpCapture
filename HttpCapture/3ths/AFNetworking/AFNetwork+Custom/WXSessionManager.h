//
//  WXSessionManager.h
//  weixindress
//
//  Created by 杨帆 on 16/3/17.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "AFHTTPSessionManager+Custom.h"


typedef NS_ENUM(NSInteger, SessionCachePolicy) {
    SessionCachePolicyUseLocalFirst    = 0,
    SessionCachePolicyIgnoreLocal      = 1,
};

@interface WXSessionManager : AFHTTPSessionManager

+ (nullable NSMutableURLRequest * )requestWithMethod:(nonnull NSString *)method
                                 URLString:(nonnull NSString *)URLString
                                parameters:(nullable id)parameters;


+ (nullable NSMutableURLRequest *)requestWithMethod:(nonnull NSString *)method
                                 URLString:(nonnull NSString *)URLString
                           notChangeScheme:(BOOL)notChangeScheme
                                parameters:(nullable id)parameters;
                       


- (nullable NSURLSessionDataTask *)GETRequest:(nonnull NSURLRequest *)request
                             success:(nullable void (^)(NSURLSessionDataTask * __nullable task, id __nullable responseObject))success
                             failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;

- (nullable NSURLSessionDataTask *)GETRequest:(nonnull NSURLRequest *)request
                     notChangeScheme:(BOOL)notChangeScheme
                             success:(nullable void (^)(NSURLSessionDataTask * __nullable task, id __nullable responseObject))success
                             failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;

- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
                              filePath:(nullable NSString *)filePath
                               need304:(BOOL)need304
                                params:(nullable id)params
                               success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;



//- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
//                                       filePath:(nullable NSString *)filePath
//                   needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
//                                        need304:(BOOL)need304
//                                  needUpdate304:(BOOL)needUpdate304
//                                         params:(nullable id)params
//                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
//                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;
//
//- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
//                                       filePath:(nullable NSString *)filePath
//                                    cachePolicy:(SessionCachePolicy)cachePolicy
//                   needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
//                                        need304:(BOOL)need304
//                                  needUpdate304:(BOOL)needUpdate304
//                                         params:(nullable id)params
//                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
//                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;

- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
                                       filePath:(nullable NSString *)filePath
                                    cachePolicy:(SessionCachePolicy)cachePolicy
                   needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
                                        need304:(BOOL)need304
                                  needUpdate304:(BOOL)needUpdate304
                                         params:(nullable id)params
                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;

- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
                                       filePath:(nullable NSString *)filePath
                                    cachePolicy:(SessionCachePolicy)cachePolicy
                   needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
                                        need304:(BOOL)need304
                                  needUpdate304:(BOOL)needUpdate304
                                         params:(nullable id)params
                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;


- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
                                       filePath:(nullable NSString *)filePath
                                    cachePolicy:(SessionCachePolicy)cachePolicy
                   needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
                                        need304:(BOOL)need304
                                  needUpdate304:(BOOL)needUpdate304
                                    need304Data:(BOOL)need304Data
                                         params:(nullable id)params
                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure;
 

- (nullable NSArray *)batchGET:(nullable NSArray *)URLStringArray
           parameters:(nullable NSArray*)parameters
        progressBlock:(nullable void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock
      completionBlock:(nullable void (^)(NSArray * __nullable tasks))success;

+(void)SavelastModifiedForResponse:(nonnull NSHTTPURLResponse *)response;


@end
