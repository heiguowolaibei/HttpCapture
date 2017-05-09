//
//  AFURLRequestSerialization+Custom.h
//  weixindress
//
//  Created by 杨帆 on 16/3/17.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//


#import "AFURLRequestSerialization.h"

@interface AFHTTPRequestSerializer (Custom)

@property(nonatomic,assign) BOOL isNoCache;

@end
