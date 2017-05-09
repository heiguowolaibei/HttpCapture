//
//  UIScrollView+SwizzleMethod.m
//  weixindress
//
//  Created by liuyihao1216 on 15/10/27.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

#import "UIScrollView+SwizzleMethod.h"

@implementation UIScrollView(SwizzleMethod)

- (void)WXSetScrollsToTop:(BOOL)value{
    if (self.tag == 1216) {
        NSLog(@"sadf");
    }
    value = false;
    [self WXSetScrollsToTop:value];
}


@end
