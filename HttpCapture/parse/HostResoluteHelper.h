//
//  HostResoluteHelper.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/29.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HostResoluteOperation.h"

@interface HostResoluteHelper : NSObject

+ (instancetype)shareInstance;
- (void)parseHost:(NSString *)host block:(QQHostResolutionOperationCallback)block;

@end
