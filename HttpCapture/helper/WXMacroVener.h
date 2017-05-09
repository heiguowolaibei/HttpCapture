//
//  WXMacroVener.h
//  weixindress
//
//  Created by louyunping on 15/4/28.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

#ifndef weixindress_WXMacroVener_h
#define weixindress_WXMacroVener_h

#ifdef DEBUG
#define DLog(...) \
{\
NSString *logstr=[NSString stringWithFormat:__VA_ARGS__];\
NSLog(@"MDLog-%@",logstr); \
}
#else
#define DLog(...)  do {} while (0)
#endif


#define SYSTEM_VERSION      [[[UIDevice currentDevice] systemVersion] doubleValue]     
#endif
