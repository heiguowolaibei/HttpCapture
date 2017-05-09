//
//  UIImage+Crop.h
//  weixindress
//
//  Created by ECCSQ-lawrenceluo on 15/3/16.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

#ifndef weixindress_UIImage_Crop_h
#define weixindress_UIImage_Crop_h

#import <UIKit/UIKit.h>


@interface UIImage (Crop)

/*
 * @brief crop image
 */

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage*)cropImageWithRect:(CGRect)cropRect;

- (UIImage*)cropRoundImageWithRect:(CGRect)cropRect;

- (UIImage *)imageByResizingToSize:(CGSize)size;

+ (UIImage *)circleImage:(UIImage *)image;

@end



#endif
