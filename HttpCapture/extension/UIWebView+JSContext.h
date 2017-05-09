//
//  UIWebView+JSContext.h
//  weixindress
//
//  Created by 杨帆 on 15/11/16.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface UIWebView (JSContext)
-(JSContext*)switchAlert;
-(JSContext*)switchLog;
-(JSValue *)switchLoggg;
- (BOOL)shouldHideAlert;
- (void)setShouldHideAlert:(BOOL)value;
- (dispatch_queue_t)logQueue;
@end


//@interface UIAlertView(JSContext)
//
//-(void)switchShow;
//
//@end















