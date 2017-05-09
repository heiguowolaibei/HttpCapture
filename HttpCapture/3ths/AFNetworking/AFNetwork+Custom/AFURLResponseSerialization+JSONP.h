//
//  AFURLResponseSerialization+JSONP.h
//  weixindress
//
//  Created by 杜永超 on 16/1/12.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//


#import "AFURLResponseSerialization.h"

@interface AFHTTPResponseSerializer(JSONP)

@property (nonatomic, assign) BOOL useJSONP;

@end

@interface AFJSONResponseSerializer(JSONP)

- (id)handleData:(NSData *)data;

@end
