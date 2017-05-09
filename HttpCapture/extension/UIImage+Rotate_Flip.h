//
//  UIImage+Rotate_Flip.h
//  weixindress
//
//  Created by ECCSQ-lawrenceluo on 15/3/12.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

#ifndef weixindress_UIImage_Rotate_Flip_h
#define weixindress_UIImage_Rotate_Flip_h

#import <UIKit/UIKit.h>

enum {
    enSvCropClip,               // the image size will be equal to orignal image, some part of image may be cliped
    enSvCropExpand,             // the image size will expand to contain the whole image, remain area will be transparent
};
typedef NSInteger SvCropMode;

@interface UIImage (Rotate_Flip)

/*
 * @brief rotate image 90 withClockWise
 */
- (UIImage*)rotate90Clockwise;

/*
 * @brief rotate image 90 counterClockwise
 */
- (UIImage*)rotate90CounterClockwise;

/*
 * @brief rotate image 180 degree
 */
- (UIImage*)rotate180;

/*
 * @brief rotate image to default orientation
 */
- (UIImage*)rotateImageToOrientationUp;

/*
 * @brief flip horizontal
 */
- (UIImage*)flipHorizontal;

/*
 * @brief flip vertical
 */
- (UIImage*)flipVertical;

/*
 * @brief flip horizontal and vertical
 */
- (UIImage*)flipAll;

/*
* @brief rotate image with radian
*/
- (UIImage*)rotateImageWithRadian:(CGFloat)radian cropMode:(SvCropMode)cropMode;


@end


#endif
