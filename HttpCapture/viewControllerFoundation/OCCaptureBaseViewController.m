//
//  OCCaptureBaseViewController.m
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/7.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "OCCaptureBaseViewController.h"
#import "SidebarMenuViewController.h"
#import "HttpCapture-swift.h"

@interface OCCaptureBaseViewController ()

@end

@implementation OCCaptureBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configLeftBtn {
    [[self.self.navigationBar viewWithTag:1000] removeFromSuperview];
    if ([self.self.navigationBar viewWithTag:1002] == nil)
    {
        UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 20, 44, 44);
        leftBtn.tag = 1002;
        
        if (self.navigationController.viewControllers.count > 1)
        {
            [leftBtn setImage:[CommonImageCache getImageWithNamed:@"返回"] forState:UIControlStateNormal];
            [leftBtn setImage:[CommonImageCache getImageWithNamed:@"返回-按下"] forState:UIControlStateHighlighted];
        }
        else
        {
            [leftBtn setImage:[CommonImageCache getImageWithNamed:@"关闭"] forState:UIControlStateNormal];
            [leftBtn setImage:[CommonImageCache getImageWithNamed:@"关闭"] forState:UIControlStateHighlighted];
        }
        
        [leftBtn addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        leftBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [leftBtn setTitleColor:[UIColor fromRGB:0x666666] forState:UIControlStateNormal];
        
        [self.navigationBar addSubview:leftBtn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hasCustomNavigationBar
{
    return true;
}

- (BOOL)prefersNavigationBarHidden{
    return false;
}


@end
