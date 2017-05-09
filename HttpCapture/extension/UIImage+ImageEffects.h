//
//  UIImage+ImageEffects.h
//  PaiChat
//
//  Created by kevin on 15/2/5.
//  Copyright (c) 2015年 boleunt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffects)

-(UIImage*)applyLightEffect;
-(UIImage*)applyExtraLightEffect;
-(UIImage*)applyDarkEffect;
-(UIImage*)applyTintEffectWithColor:(UIColor*)tintColor alpha:(CGFloat)a;
-(UIImage*)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage*)maskImage;
- (UIImage *)blurryImage:(UIImage *)image
           withBlurLevel:(CGFloat)blur;
- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
+ (UIImage *) imageWithColor:(UIColor* )color size:(CGSize)size;

-(UIImage *) generateImageWithImageAndText:(CGRect)frame title:(NSString*)title tintColor:(UIColor *)color;
@end
