//
//  NSArray+Custom.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/17.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PanNavigationController.h"
#import "OCCaptureBaseViewController.h"

@interface SideBarModel : NSObject
{
    
}

@property(nonatomic,strong)NSString * name;
@property(nonatomic,strong)UIViewController * vc;
@property(nonatomic,assign)NSInteger section;
@property(nonatomic,assign)NSInteger row;

- (id)initWithName:(NSString*)name vc:(nullable UIViewController *)vc;

@end


@interface SidebarMenuViewController : OCCaptureBaseViewController <UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *menuItemViewControllers;

@property (nonatomic, strong) NSArray *menuItemNames;

@property (nonatomic, copy) NSString *sideBarButtonImageName;

@property (nonatomic, strong) UINavigationController *containerController;

@property (nonatomic, strong) UITableView *tableView;

- (void)addTargetViewControllerForIndex:(NSUInteger)index;

- (void)changeTitle:(NSString *)url;


@end
