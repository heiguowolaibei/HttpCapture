//
//  NSURLResponse+Custom.m
//  weixindress
//
//  Created by 杨帆 on 16/7/21.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "NSURLResponse+Custom.h"
#import <objc/runtime.h>

@implementation NSURLResponse (Custom)

-(id)responseObject
{
    id z = objc_getAssociatedObject(self, @selector(setResponseObject));
    return z;
}

-(void)setResponseObject:(id)responseObject
{
    objc_setAssociatedObject(self, @selector(setResponseObject), responseObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

