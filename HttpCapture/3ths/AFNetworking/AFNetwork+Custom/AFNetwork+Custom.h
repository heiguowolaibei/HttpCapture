//
//  AFNetwork+Custom.h
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#ifndef AFNetwork_Custom_h
#define AFNetwork_Custom_h
#import "AFHTTPRequestOperationManager+Custom.h"
#import "AFURLConnectionOperation+Custom.h"
#import "AFURLResponseSerialization+JSONP.h"
#import "AFURLRequestSerialization+Custom.h"
#import "af_MethodSwizzleClass.h"

#if ( ( defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090) || \
( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 ) )
#import "AFHTTPSessionManager+Custom.h"
#endif

#endif /* AFNetwork_Custom_h */
