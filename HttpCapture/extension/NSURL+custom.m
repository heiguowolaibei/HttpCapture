//
//  NSURL+custom.m
//  weixindress
//
//  Created by 杨帆 on 16/3/21.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "NSURL+custom.h"

@implementation NSURL (custom)

-(NSString *)absoluteStringNoScheme
{
    NSString *ab = self.absoluteString;
    if (self.scheme.length < ab.length)
    {
         return [self.absoluteString substringFromIndex:self.scheme.length+1];
    }
    return ab;
}


-(NSURL *)URLByRemoveHttpScheme
{
    NSString *ab = self.absoluteString;
    if ([self.scheme isEqualToString:@"http"] || [self.scheme isEqualToString:@"https"])
    {
        return [NSURL URLWithString:[ab substringFromIndex:self.scheme.length+1]];
    }
    return self;
}

@end
