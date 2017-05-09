//
//  AFHTTPRequestOperationManager+Custom.h
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager(Custom)

@property ( nonatomic, assign)BOOL isNoCache;

//@property ( nonatomic, assign)BOOL UseMemoryWidAndSkeyCookie;

@property ( nonatomic, assign)BOOL needAddToken;

/**
 是否开启runloop defalutModel
 */
@property (assign, nonatomic) BOOL bOpenDefaultModel;


// 将生成Operation的方法放到.h中，供外部可调用
- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/// 批量GET请求
- (NSArray *)batchGET:(NSArray *)URLStringArray
           parameters:(NSArray*)parameters
        progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock
      completionBlock:(void (^)(NSArray* operations))success;



@end

