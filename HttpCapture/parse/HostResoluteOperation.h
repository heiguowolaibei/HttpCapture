//
//  HostResoluteOperation.h
//  TestDevelop
//
//  Created by liuyihao1216 on 16/8/29.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QQHostInfoResolutionType) {
    kQQHostInfoResolutionTypeUnknown = -1,
    kQQHostInfoResolutionTypeNames = -2,
    kQQHostInfoResolutionTypeAddresses = -3
};

void QQHostInfoResolutionCallback(CFHostRef, CFHostInfoType , const CFStreamError *, void *);
typedef void (^QQHostResolutionOperationCallback)(QQHostInfoResolutionType type,id obj,double code);

@interface HostResoluteOperation : NSObject
{
    
}

- (id)initWithHostName:(NSString *)hostname;

- (void)startWithCallback:(QQHostResolutionOperationCallback)operation ;

@end
