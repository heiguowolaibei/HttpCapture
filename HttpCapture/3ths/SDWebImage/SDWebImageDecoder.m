/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * Created by james <https://github.com/mystcolor> on 9/28/11.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDecoder.h"

@implementation UIImage (ForceDecode)

+ (UIImage*)cutCircleImage:(UIImage *)image
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

+ (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images) {
        // Do not decode animated images
        return image;
    }
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);

    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
            infoMask == kCGImageAlphaNoneSkipFirst ||
            infoMask == kCGImageAlphaNoneSkipLast);

    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;

        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
            // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }

    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
            imageSize.width,
            imageSize.height,
            CGImageGetBitsPerComponent(imageRef),
            0,
            colorSpace,
            bitmapInfo);
    CGColorSpaceRelease(colorSpace);

    // If failed, return undecompressed image
    if (!context) return image;

    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);

    CGContextRelease(context);

    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

@end
