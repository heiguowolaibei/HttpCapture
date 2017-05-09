//
//  UIImage+Zoom.m
//  weixindress
//
//  Created by ECCSQ-lawrenceluo on 15/3/13.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//



#import "UIImage+Zoom.h"

@implementation UIImage (Zoom)

/*
 * @brief resizeImage
 * @param newsize the dimensions（pixel） of the output image
 */
- (UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode
{
    CGRect drawRect = [self caculateDrawRect:newSize resizeMode:resizeMode];
    
    UIGraphicsBeginImageContext(newSize);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
    
    CGContextSetInterpolationQuality(context, 0.8);
    
    [self drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage*)resizeImageToSize:(CGSize)newSize scale:(CGFloat)scale resizeMode:(SvResizeMode)resizeMode
{
    CGRect drawRect = [self caculateDrawRect:newSize resizeMode:resizeMode];
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
    
    CGContextSetInterpolationQuality(context, 0.8);
    
    [self drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIImage*)cutCircleImage:(UIImage *)orgImage size:(CGSize)size
{
    CGFloat side = MIN(orgImage.size.width, orgImage.size.height);
    side *= orgImage.scale;
    
    CGRect drawRect = CGRectZero;
    drawRect.size = CGSizeMake(orgImage.size.width * orgImage.scale, orgImage.size.height * orgImage.scale);
    
    if(drawRect.size.width > drawRect.size.height) {
        CGFloat scale = side / drawRect.size.height;
        drawRect.size.width *= scale;
        drawRect.size.height = side;
        drawRect.origin.x = (side - drawRect.size.width)/2;
    } else {
        CGFloat scale = side / drawRect.size.width;
        drawRect.size.width = side;
        drawRect.size.height *= scale;
        drawRect.origin.y = (side - drawRect.size.height)/2;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), NO, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect contextRect = CGRectMake(0, 0, side, side);
    
    [[UIColor clearColor] set];
    CGContextFillRect(context, contextRect);
    
    CGContextAddEllipseInRect(context, contextRect);
    CGContextClip(context);
    
    [orgImage drawInRect:drawRect];
    UIImage *clipedimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipedimage;
    
}



// caculate drawrect respect to specific resize mode
- (CGRect)caculateDrawRect:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode
{
    CGRect drawRect = CGRectMake(0, 0, newSize.width, newSize.height);
    
    CGFloat imageRatio = self.size.width / self.size.height;
    CGFloat newSizeRatio = newSize.width / newSize.height;
    
    switch (resizeMode) {
        case enSvResizeScale:
        {
            // scale to fill
            break;
        }
        case enSvResizeAspectFit:                    // any remain area is white
        {
            CGFloat newHeight = 0;
            CGFloat newWidth = 0;
            if (newSizeRatio >= imageRatio) {        // max height is newSize.height
                newHeight = newSize.height;
                newWidth = newHeight * imageRatio;
            }
            else {
                newWidth = newSize.width;
                newHeight = newWidth / imageRatio;
            }
            
            drawRect.size.width = newWidth;
            drawRect.size.height = newHeight;
            
            drawRect.origin.x = newSize.width / 2 - newWidth / 2;
            drawRect.origin.y = newSize.height / 2 - newHeight / 2;
            
            break;
        }
        case enSvResizeAspectFill:
        {
            CGFloat newHeight = 0;
            CGFloat newWidth = 0;
            if (newSizeRatio >= imageRatio) {        // max height is newSize.height
                newWidth = newSize.width;
                newHeight = newWidth / imageRatio;
            }
            else {
                newHeight = newSize.height;
                newWidth = newHeight * imageRatio;
            }
            
            drawRect.size.width = newWidth;
            drawRect.size.height = newHeight;
            
            drawRect.origin.x = newSize.width / 2 - newWidth / 2;
            drawRect.origin.y = newSize.height / 2 - newHeight / 2;
            
            break;
        }
        default:
            break;
    }
    
    return drawRect;
}

@end


