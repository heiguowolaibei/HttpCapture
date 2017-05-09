//
//  WXSessionManager.m
//  weixindress
//
//  Created by 杨帆 on 16/3/17.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "WXSessionManager.h"
#import "HttpCapture-swift.h"
#import "AFHTTPSessionManager+Custom.h"
#import "NSURLResponse+Custom.h"
#import "String+Utils.h"

static AFHTTPRequestSerializer * _requestSerializer;

@interface AFHTTPSessionManager()
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end


@implementation WXSessionManager

#pragma mark -

- (instancetype)init {
    self = [super initWithBaseURL:nil];
    [self setNeedAddToken:true];
    [self setIsNoCache:true];
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    return [self initWithBaseURL:url sessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    return [self initWithBaseURL:nil sessionConfiguration:configuration];
}

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(nullable id)parameters
{
    return [self requestWithMethod:method URLString:URLString notChangeScheme:false parameters:parameters noCache:true];
}


+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                           notChangeScheme:(BOOL)notChangeScheme
                                parameters:(nullable id)parameters
                                   noCache:(BOOL)isNoCache
{
 
    if(_requestSerializer == nil)
    {
        _requestSerializer = [AFHTTPRequestSerializer new];
        _requestSerializer.isNoCache = isNoCache;
    }
    _requestSerializer.isNoCache = isNoCache;
    
    return [_requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:nil];
}

- (NSURLSessionDataTask *)GETRequest:(NSURLRequest *)request
                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
     return [self GETRequest:request notChangeScheme:false success:success failure:failure];
}


- (NSURLSessionDataTask *)GETRequest:(NSURLRequest *)request
                     notChangeScheme:(BOOL)notChangeScheme
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask  = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    [dataTask resume];
    return dataTask;
}

+(void)saveLastModifiedForURLString:(NSString *)URLStr lastModifiedString:(NSString*)lastModifiedStr
{
    [[NSUserDefaults standardUserDefaults]setObject:lastModifiedStr forKey:[NSString stringWithFormat:@"LastModified_%@",URLStr]];
}

-(NSString *)getLastModifiedForURLString:(NSString*)URLStr
{
   
    id z = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"LastModified_%@",URLStr]];
    if([z isKindOfClass:[NSString class]])
    {
        return z;
    }
    return nil;
}

+(void)SavelastModifiedForResponse:(NSHTTPURLResponse *)response
{
    NSDictionary *headDic = response.allHeaderFields;
    NSString *URLString = response.URL.absoluteString;
    NSString *lastModifiedStr = headDic[@"Last-Modified"];
    if(lastModifiedStr)
    {
        [WXSessionManager saveLastModifiedForURLString:[URLString stringByRemoveHTTPScheme] lastModifiedString:lastModifiedStr];
    }
}


//- (nullable NSURLSessionDataTask *)downloadFileRemote:(nonnull NSString *)URLString
//                                       filePath:(nullable NSString *)filePath
//                                        need304:(BOOL)need304
//                                  needUpdate304:(BOOL)needUpdate304
//                                         params:(nullable id)params
//                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
//                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure
//{
//    
//}

- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
                                       filePath:(nullable NSString *)filePath
                                    cachePolicy:(SessionCachePolicy)cachePolicy
                   needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
                                        need304:(BOOL)need304
                                  needUpdate304:(BOOL)needUpdate304
                                         params:(nullable id)params
                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure
{
    return [self downloadFile:URLString filePath:filePath cachePolicy:cachePolicy needCustomResponseSerializer:needCustomResponseSerializer need304:need304 needUpdate304:needUpdate304 need304Data:false params:nil success:success failure:failure];
}


- (nullable NSURLSessionDataTask *)downloadFile:(nonnull NSString *)URLString
                                       filePath:(nullable NSString *)filePath
                                    cachePolicy:(SessionCachePolicy)cachePolicy
                   needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
                                        need304:(BOOL)need304
                                  needUpdate304:(BOOL)needUpdate304
                                    need304Data:(BOOL)need304Data
                                         params:(nullable id)params
                                        success:(nullable void (^)(NSURLSessionDataTask * __nullable task,NSInteger statusCode,id __nullable responseObject))success
                                        failure:(nullable void (^)(NSURLSessionDataTask * __nullable task, NSError * __nullable error))failure{
    
    if(cachePolicy == SessionCachePolicyUseLocalFirst && [[NSFileManager defaultManager]fileExistsAtPath:filePath])
    {
        
//        
//        return [self GET:filePath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//                if (success) success(task,200,responseObject);
//                    } failure:failure];
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            if(data != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(needCustomResponseSerializer == true)
                    {
                        id responseObj = [self.responseSerializer responseObjectForResponse:nil data:data error:nil ];
                        if(responseObj)
                        {
                            success(nil,201,responseObj);

                        }
                        else
                        {
                            failure(nil,nil);

                        }
                    }
                    else
                    {
                        success(nil,200,data);
                    }
                   
                });
            }
            else
            {
                [self downloadFile:URLString filePath:filePath needCustomResponseSerializer:needCustomResponseSerializer need304:need304 needUpdate304:need304 need304Data:need304Data params:params success:success failure:failure];
            }
                
        });
    }
    else
    {
        return [self downloadFile:URLString filePath:filePath needCustomResponseSerializer:needCustomResponseSerializer  need304:need304 needUpdate304:need304 need304Data:need304Data  params:params success:success failure:failure];
    }
    
    return nil;

}




- (NSURLSessionDataTask *)downloadFile:(NSString *)URLString
                              filePath:(NSString *)filePath
          needCustomResponseSerializer:(BOOL)needCustomResponseSerializer
                               need304:(BOOL)need304
                         needUpdate304:(BOOL)needUpdate304
                           need304Data:(BOOL)need304Data
                                params:(id)params
                               success:(void (^)(NSURLSessionDataTask *task,NSInteger statusCode ,id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    if(!needCustomResponseSerializer)
    {
        self.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    }
    NSMutableIndexSet *d = self.responseSerializer.acceptableStatusCodes.mutableCopy;
    [d addIndex:304];
    self.responseSerializer.acceptableStatusCodes = d;
    NSMutableURLRequest *request = [WXSessionManager requestWithMethod:@"GET" URLString:URLString parameters:params];
    
    if(need304)
    {
        if((filePath&&[[NSFileManager defaultManager]fileExistsAtPath:filePath]) || filePath == nil)
        {
            NSString *lm = [self getLastModifiedForURLString:[URLString stringByRemoveHTTPScheme]];
            if(lm)
            {
                [request addValue:lm forHTTPHeaderField:@"If-Modified-Since"];
            }
        }
    }
    
    return [self GETRequest:request  success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]])
        {
            id responseData = task.response.responseObject;
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            if ([response.URL.absoluteString isEqualToString:request.URL.absoluteString])
            {
                if(response.statusCode == 200)
                {
                    if([responseData isKindOfClass:[NSData class]])
                    {
                        if (filePath != nil)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                
                                NSString *dicPath = [filePath stringByDeletingLastPathComponent];
                                BOOL isPath = false;
                                if(![[NSFileManager defaultManager] fileExistsAtPath:dicPath isDirectory:&isPath] || isPath == false)
                                {
                                    [[NSFileManager defaultManager] createDirectoryAtPath:dicPath withIntermediateDirectories:true attributes:nil error:nil];
                                }
                          
                                BOOL re = [((NSData*)responseData) writeToFile:filePath atomically:true];
                                if (re && needUpdate304 && need304)
                                {
                                    [WXSessionManager SavelastModifiedForResponse:response];
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (success) success(task,response.statusCode,responseObject);
                                });
                            });
                        }
                        else
                        {
                            if (success) success(task,response.statusCode,responseObject);
                            return;
                        }
                    }
                }
                else if(response.statusCode == 304)
                {
                    if(need304Data&&filePath!=nil)
                    {
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            NSData *data = [NSData dataWithContentsOfFile:filePath];
                            id responseObj2 = nil;
                            if (data) {
                                responseObj2 = [self.responseSerializer responseObjectForResponse:response data:data error:nil];
                            }
                        
                            if (success)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(task,response.statusCode,responseObj2);

                                });
                            }
                        });

                      
                    }
                    else
                    {
                        if (success) success(task,response.statusCode,responseObject);
                        return;
                    }
                }
            }
        }
        else {
            if (failure) failure(task,[NSError new]);
        }
    } failure:failure];

    
}


- (NSURLSessionDataTask *)downloadFile:(NSString *)URLString
                              filePath:(NSString *)filePath
                               need304:(BOOL)need304
                                params:(id)params
                               success:(void (^)(NSURLSessionDataTask *task,NSInteger statusCode ,id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return [self downloadFile:URLString filePath:filePath needCustomResponseSerializer:false  need304:need304 needUpdate304:need304 need304Data:false  params:params success:success failure:failure];
}

#pragma mark - batchGET

- (NSArray *)batchGET:(NSArray *)URLStringArray
           parameters:(NSArray*)parameters
        progressBlock:(void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock
      completionBlock:(void (^)(NSArray* tasks))success
{
    
    NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:URLStringArray.count];
    dispatch_group_t group = dispatch_group_create();
    __block NSUInteger totalNumberOfTasks = URLStringArray.count;
    
    for(int i = 0 ; i < URLStringArray.count ; i++)
    {
        dispatch_group_enter(group);
        
        NSString *URLString = URLStringArray[i];
        id parameter = parameters[i];
        NSURLSessionDataTask *dataTask = [self GET:URLString parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if (progressBlock) {
                NSUInteger numberOfFinishedTasks = [[tasks indexesOfObjectsPassingTest:^BOOL(id op, NSUInteger __unused idx,  BOOL __unused *stop) {
                    return [op isFinished];
                }] count];
                NSLog(@"success");
                progressBlock(numberOfFinishedTasks,totalNumberOfTasks);
            }
            dispatch_group_leave(group);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (progressBlock) {
                NSUInteger numberOfFinishedTasks = [[tasks indexesOfObjectsPassingTest:^BOOL(id op, NSUInteger __unused idx,  BOOL __unused *stop) {
                    return [op isFinished];
                }] count];
                NSLog(@"fail");
                progressBlock(numberOfFinishedTasks,totalNumberOfTasks);
            }
            dispatch_group_leave(group);
        }];
        [tasks addObject:dataTask];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (success) {
            success(tasks);
        }
    });
    
    return tasks;
}

@end
