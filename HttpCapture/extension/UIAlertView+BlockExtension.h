//
//  UIAlertView+BlockExtension.h
//  QQKala
//
//  Created by frost on 12-9-26.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertView (BlockExtension) <UIAlertViewDelegate>

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTItle:(NSString*)otherButtonTitle  completionBlock:(void (^)(NSUInteger buttonIndex))block;

@end
