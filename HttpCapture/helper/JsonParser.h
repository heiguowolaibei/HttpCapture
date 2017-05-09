//
//  JsonParser.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/29.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonParser : NSObject

+ (id)jsonpParse:(NSData *)data;

@end
