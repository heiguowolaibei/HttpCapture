//
//  ASIHTTPRequest+Custom.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/16.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (Custom)

- (BOOL)isFinished;

- (void)setISFinished:(BOOL)isfinish;

@end
