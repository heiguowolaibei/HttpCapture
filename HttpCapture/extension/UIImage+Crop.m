//
//  UIImage+Crop.m
//  weixindress
//
//  Created by ECCSQ-lawrenceluo on 15/3/16.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//


#import "UIImage+Crop.h"

@implementation UIImage (Crop)

/*
 * @brief crop image
 */

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *bg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return bg;
}

+ (UIImage*)circleImage:(UIImage *)image
{
    CGFloat diameter  = image.size.width > image.size.height? image.size.height:image.size.width;
    CGFloat radius = diameter/2;
    UIGraphicsBeginImageContext(CGSizeMake(diameter, diameter));
    
    CGRect drawRect = CGRectMake( 0 ,0,image.size.width,image.size.height);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(gc, 0, diameter);
    CGContextScaleCTM(gc, 1, -1);
    
    CGContextAddArc(gc,radius,radius,radius , 0, 2*M_PI, 0);
    CGContextClosePath(gc);
    CGContextClip(gc);
    CGContextDrawImage(gc,drawRect , image.CGImage);
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}


- (UIImage*)cropImageWithRect:(CGRect)cropRect
{
    CGRect drawRect = CGRectMake(-cropRect.origin.x , -cropRect.origin.y, self.size.width * self.scale, self.size.height * self.scale);
    
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
    
    [self drawInRect:drawRect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)cropRoundImageWithRect:(CGRect)cropRect
{
    CGRect drawRect = CGRectMake(0 , 0, cropRect.size.width, cropRect.size.width);
    
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, drawRect);
    CGContextAddArc(context, drawRect.size.width/2.0, drawRect.size.width/2.0, drawRect.size.width/2.0, 0, M_PI * 2, 0);
    CGContextClip(context);
    [self drawInRect:drawRect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage *)imageByResizingToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, .0);
    [self drawInRect:CGRectMake(.0, .0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end