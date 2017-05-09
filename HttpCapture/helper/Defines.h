//
//  Defines.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/14.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

//#define TODictionary(object) (NSDictionary *)[OCDValueFormatter objectAsClass:[NSDictionary class] withObject:object]

#ifndef DebugLog
#define DebugLog(fmt, ...) NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#define DebugLog(fmt, ...)
#endif

#endif /* Defines_h */
