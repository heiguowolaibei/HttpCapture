/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"

static char imageURLKey;
static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
static char TAG_ACTIVITY_SHOW;

@implementation UIImageView (WebCache)

- (BOOL)bHaveLoadedImage {
    NSObject *obj = objc_getAssociatedObject(self, @selector(bHaveLoadedImage));
    if (obj) {
        return ((NSNumber *)obj).boolValue;
    }
    return  NO;
}

- (void)setBHaveLoadedImage:(BOOL)value {
    objc_setAssociatedObject(self, @selector(bHaveLoadedImage), @(value), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)bNeedFadeAnimation {
    NSObject *obj = objc_getAssociatedObject(self, @selector(bNeedFadeAnimation));
    if (obj) {
        return ((NSNumber *)obj).boolValue;
    }
    return  true;
}

- (void)setBNeedFadeAnimation:(BOOL)value {
    objc_setAssociatedObject(self, @selector(bNeedFadeAnimation), @(value), OBJC_ASSOCIATION_ASSIGN);
}

- (void)sd_setImageWithURL:(NSURL *)url {
    [self sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageContinueInBackground progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageContinueInBackground progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageContinueInBackground progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageContinueInBackground progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)addFadeAniamtion
{
    if([self bNeedFadeAnimation] && ![self bHaveLoadedImage])
    {
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=0.5;
        theAnimation.repeatCount=1;
        theAnimation.fromValue=[NSNumber numberWithFloat:0.0];
        theAnimation.toValue=[NSNumber numberWithFloat:1.0];
        [self.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    }


}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
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
 
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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

- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self sd_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];    
}

- (NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)sd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self sd_cancelCurrentAnimationImagesLoad];
    __weak __typeof(self)wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    [self sd_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)sd_cancelCurrentAnimationImagesLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}


#pragma mark -
- (TYMActivityIndicatorView *)activityIndicator {
    return (TYMActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(TYMActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)setShowActivityIndicatorView:(BOOL)show{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, [NSNumber numberWithBool:show], OBJC_ASSOCIATION_RETAIN);
}

//-(void)hideIndictor
//{
//    self.removeActivityIndicator
//}

- (BOOL)showActivityIndicatorView{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)getIndicatorStyle{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}

- (void)addActivityIndicator {
    if (!self.activityIndicator) {
        self.activityIndicator = [[TYMActivityIndicatorView alloc] initWithActivityIndicatorStyle:(TYMActivityIndicatorViewStyleLarge)   ];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

        dispatch_main_async_safe(^{
            [self addSubview:self.activityIndicator];
            self.activityIndicator.center = self.center;
//            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
//                                                             attribute:NSLayoutAttributeCenterX
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:self
//                                                             attribute:NSLayoutAttributeCenterX
//                                                            multiplier:1.0
//                                                              constant:0.0]];
//            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
//                                                             attribute:NSLayoutAttributeCenterY
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:self
//                                                             attribute:NSLayoutAttributeCenterY
//                                                            multiplier:1.0
//                                                              constant:0.0]];
        });
    }

    dispatch_main_async_safe(^{
        [self.activityIndicator startAnimating];
    });

}

- (void)removeActivityIndicator {
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}




@end
