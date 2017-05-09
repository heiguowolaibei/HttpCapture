//
//  UIWebView+JSContext.m
//  weixindress
//
//  Created by 杨帆 on 15/11/16.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

#import "UIWebView+JSContext.h"
#import "UIViewAdditions.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "HttpCapture-swift.h"
#import <objc/runtime.h>

typedef void(^AlertBlock)(NSString*);
typedef void(^LogBlock)(NSString*);
typedef void(^CanPanBackBlock)(BOOL);

@implementation UIWebView (JSContext)


-(JSContext*)switchAlert
{
    JSContext *context =  [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    __weak UIWebView * weakWebView = self;
    AlertBlock z = ^(NSString *msg) {
        if ([weakWebView shouldHideAlert])
        {
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"asdf dispatch_get_main_queue");
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil , nil];
                [al show];
            });
        }
    };
    [context setObject:z forKeyedSubscript:@"alert"];
    
    CanPanBackBlock a = ^(BOOL canPanBack) {
         UIViewController * vc =  [weakWebView viewController];
         if(vc)
         {
             vc.fd_interactivePopDisabled = !canPanBack;
         }
    };

    [context setObject:a forKeyedSubscript:@"setCanPanBack"];
    
    return context;
}

-(JSContext*)switchLog
{
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    LogBlock z = ^(NSString *msg) {
        __block NSString * message = msg;
        dispatch_async([self logQueue], ^{
            NSString * time = [[DateFormatterManager sharedInstance] parseStyleSync:0 date:[NSDate date]];
            message = [NSString stringWithFormat:@"%@:%@\r\n\r\n",time,msg];
            NSLog(@"message = %@",message);
            
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString * diskCachePath = [paths[0] stringByAppendingPathComponent:@"/consoleLog.txt"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
            {
                [[NSFileManager defaultManager] createFileAtPath:diskCachePath contents:[NSData data] attributes:nil];
            }
            NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:diskCachePath];
            [myHandle seekToEndOfFile];
            [myHandle writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
            
//            NSString* s = [[NSString alloc] initWithContentsOfFile:diskCachePath encoding:NSUTF8StringEncoding error:nil];
//            NSLog(@"sss = %@",s);
        });
    };
    
    [[context objectForKeyedSubscript:@"console"] setObject:z forKeyedSubscript:@"log"];
    
    return context;
}

-(JSValue *)switchLoggg
{
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSValue *v = [[context objectForKeyedSubscript:@"console"] objectForKeyedSubscript:@"log"];
    return v;
}

- (dispatch_queue_t)logQueue{
    dispatch_queue_t obj = objc_getAssociatedObject(self, @selector(logQueue));
    if (obj) {
        return obj;
    }
    obj = dispatch_queue_create("consolelog_queue", DISPATCH_QUEUE_SERIAL);
    [self setLogQueue:obj];
    return obj;
}

- (void)setLogQueue:(dispatch_queue_t)queue
{
    objc_setAssociatedObject(self, @selector(logQueue), queue, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldHideAlert {
    NSObject *obj = objc_getAssociatedObject(self, @selector(shouldHideAlert));
    if (obj) {
        return ((NSNumber *)obj).boolValue;
    }
    return  false;
}

- (void)setShouldHideAlert:(BOOL)value {
    objc_setAssociatedObject(self, @selector(shouldHideAlert), @(value), OBJC_ASSOCIATION_ASSIGN);
}
@end


//@implementation UIAlertView(JSContext)
//
//-(void)switchShow
//{
//    NSLog(@"replace show=%@",[NSThread currentThread]);
//    [self switchShow];
//}
//
//@end






















