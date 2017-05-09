//
//  NSURL+custom.h
//  weixindress
//
//  Created by 杨帆 on 16/3/21.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (custom)

-(NSString *)absoluteStringNoScheme;
-(NSURL *)URLByRemoveHttpScheme;
@end
