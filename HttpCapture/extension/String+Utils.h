//
//  String+Utils.h
//  weixindress
//
//  Created by ECCSQ-lawrenceluo on 15/5/1.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

#ifndef weixindress_String_Utils_h
#define weixindress_String_Utils_h


@interface NSString (Utils)

/*
 * @brief url encode  to nsstring
 */
- (NSString*)stringWithURLEncode;

- (NSString*)stringByRemoveHTTPScheme;
/*
 * @escape to nsstring
 */
- (NSString*)stringEscape;

- (NSString*)stringUnEscape;

- (nullable id)objectFromJSONString;

+ (NSString *)getAstroWithMonth:(int)m day:(int)d;

- (NSInteger)caculateStringLength;

- (NSString *)getMimeType;

@end




#endif
