//
//  AFHTTPSessionManager+Custom.h
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFHTTPSessionManager(Custom)

/*
 所有修改在af_MethodSwizzleClass中使用方法替换实现
 在升级AF时，在不影响原实现的情况下，可以再次应用自定义修改，而无需比对修改源文件
 */

/// 不使用本地缓存
@property ( nonatomic, assign)BOOL isNoCache;

/// 添加g_tk g_ty参数
@property ( nonatomic, assign)BOOL needAddToken;

@property ( nonatomic, assign) BOOL bOpenDefaultModel;

@end
