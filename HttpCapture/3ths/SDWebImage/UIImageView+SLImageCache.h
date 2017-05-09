//
//  UIImageView+SLImageCache.h
//  weixindress
//
//  Created by liuyihao1216 on 16/7/29.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"
#import "LLARingSpinnerView.h"
#import "TYMActivityIndicatorView.h"

@interface UIImageView (SLImageCache)

- (void)sl_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

@end
