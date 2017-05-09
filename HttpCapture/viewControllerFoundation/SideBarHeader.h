//
//  SideBarHeader.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/7.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#ifndef SideBarHeader_h
#define SideBarHeader_h

typedef enum {
    ToggleOpen = 0,         //sidebar展开
    ToggleClose = 1         //sidebar闭合
} ToggleState;

@protocol SideBarDelegate <NSObject>

@optional
- (void)toggle:(ToggleState)state;
- (void)swipePanGestureHandler:(UIPanGestureRecognizer * )panGesture;

@end

@protocol SideBarItemDelegate <NSObject>

@optional
- (void)selectIndexPath:(NSIndexPath *)indexPath animationFinishBlock:(void (^)(BOOL finish))block;

- (NSIndexPath *)getSearchWebControllerIndexPath;

- (NSIndexPath *)getMenuItemIndexPath:(UIViewController *)menuitem;

- (void)setToolbarURL:(NSString*)url;

- (void)clearSnapShotsArray;

- (void)replaceWebView;

- (UITableView *)getSideBarTableView;

- (void)pushItemViewCtrl:(int)index;

@end


#endif /* SideBarHeader_h */
