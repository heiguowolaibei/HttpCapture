//
//  UIImage+Zoom.h
//  weixindress
//
//  Created by ECCSQ-lawrenceluo on 15/3/13.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

#ifndef weixindress_UIImage_Zoom_h
#define weixindress_UIImage_Zoom_h


#import <UIKit/UIKit.h>

enum {
    enSvResizeScale,            // image scaled to fill
    enSvResizeAspectFit,        // image scaled to fit with fixed aspect. remainder is transparent
    enSvResizeAspectFill,       // image scaled to fill with fixed aspect. some portion of content may be cliped
};
typedef NSInteger SvResizeMode;



@interface UIImage (Zoom)

/*
 * @brief resizeImage
 * @param newsize the dimensions（pixel） of the output image
 */
- (UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode;
- (UIImage*)resizeImageToSize:(CGSize)newSize scale:(CGFloat)scale resizeMode:(SvResizeMode)resizeMode;
+ (UIImage*)cutCircleImage:(UIImage *)orgImage size:(CGSize)size;
@end




#endif



