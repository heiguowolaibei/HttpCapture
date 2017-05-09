//
//  UIImageView+SLImageCache.m
//  weixindress
//
//  Created by liuyihao1216 on 16/7/29.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "UIImageView+SLImageCache.h"
#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"

@implementation UIImageView (SLImageCache)

static char imageURLKey;

- (void)sl_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sl_sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageContinueInBackground progress:nil completed:completedBlock];
}

- (void)sl_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        
        // check if activityView is enabled or not
        if ([self showActivityIndicatorView]) {
            [self addActivityIndicator];
        }
        
        __weak __typeof(self)wself = self;
        
        id <SDWebImageOperation> operation = [[SDWebImageManager sharedSLManager] downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [wself removeActivityIndicator];
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (!wself) return;
                if (image) {
                    wself.image = image;
                    if(cacheType != SDImageCacheTypeMemory)
                    {
                        [wself addFadeAniamtion];
                    }
                    
                    //                    [wself setNeedsLayout];
                    
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        if(cacheType != SDImageCacheTypeMemory)
                        {
                            [wself addFadeAniamtion];
                        }
                        //                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            [self removeActivityIndicator];
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

@end
