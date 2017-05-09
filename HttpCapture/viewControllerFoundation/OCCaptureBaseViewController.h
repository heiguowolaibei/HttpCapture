//
//  OCCaptureBaseViewController.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/7.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarHeader.h"

@interface OCCaptureBaseViewController : UIViewController<SideBarItemDelegate>
{
    
}

@property (nonatomic, weak,nullable) id<SideBarItemDelegate> delegate;

- (void)configLeftBtn;

@end
