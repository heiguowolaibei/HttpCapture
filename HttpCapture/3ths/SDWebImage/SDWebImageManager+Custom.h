//
//  SDWebImageManager+Custom.h
//  weixindress
//
//  Created by 杨帆 on 16/3/21.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import "SDWebImageManager.h"

@interface SDWebImageManager (Custom)

- (id <SDWebImageOperation>)customSwizzle_downloadImageWithURL:(NSURL *)url
                                                options:(SDWebImageOptions)options
                                               progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                              completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;
- (id <SDWebImageOperation>)downloadWEBPImageWithURL:(NSURL *)url
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

@end
