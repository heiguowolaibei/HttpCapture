//
//  UIScrollView+MJRefreshCustom.h
//  weixindress
//
//  Created by 杨帆 on 16/2/24.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIScrollView+MJRefresh.h"
#import "UIScrollView+MJExtension.h"
#import "UIView+MJExtension.h"
#import "MJRefreshConst.h"

#import "MJRefreshNormalHeader.h"
#import "MJRefreshGifHeader.h"

#import "MJRefreshBackNormalFooter.h"
#import "MJRefreshBackGifFooter.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshAutoGifFooter.h"

@interface MJRefreshJZFooter : MJRefreshAutoStateFooter

@property(assign,nonatomic) BOOL needAdjustContentSize;

@property(assign,nonatomic) CGFloat beginOffset;
@property(assign,nonatomic) float delayTime;

@end

@interface MJRefreshJZBaseHeader : MJRefreshStateHeader

@property(retain,nonatomic) UIFont *font;
@property(retain,nonatomic) UIColor *textColor;
@property(assign,nonatomic) BOOL updatedTimeHidden;

@end

@interface JZMainRefreshHeader : MJRefreshJZBaseHeader

-(void) isMain;

@end

@interface MJRefreshJZHeader : MJRefreshJZBaseHeader


@end

@interface JZAnimationLayer : CAReplicatorLayer

-(void)start;
-(void)invalid;

@end


@interface UIScrollView (MJRefreshCustom)
- (JZMainRefreshHeader *)addJDMainHeaderViewWithRefreshingBlock:(void (^)())block;
- (MJRefreshJZFooter *)addLegendFooterWithRefreshingBlock:(void (^)())block;
- (MJRefreshJZHeader *)addJDHeaderViewWithRefreshingBlock:(void (^)())block dateKey:(NSString *)dateKey;
- (MJRefreshJZBaseHeader *)addLegendHeaderWithRefreshingBlock:(void (^)())block dateKey:(NSString *)dateKey;
- (MJRefreshJZFooter *)addLegendFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action;
- (MJRefreshJZHeader *)addJDHeaderViewWithRefreshingBlock:(void (^)())block;
- (void)removeHeader;
- (void)removeFooter;
@end
