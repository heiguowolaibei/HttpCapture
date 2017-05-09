//
//  UIAlertView+BlockExtension.m
//  QQKala
//
//  Created by frost on 12-9-26.
//
//

#import "UIAlertView+BlockExtension.h"
#import <objc/runtime.h>

@implementation UIAlertView (BlockExtension)

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTItle:(NSString*)otherButtonTitle  completionBlock:(void (^)(NSUInteger buttonIndex))block
{
	if (self = [self init])
    {
        self.title = title;
        self.message = message;
        self.delegate = self;
		if (cancelButtonTitle)
        {
			[self addButtonWithTitle:cancelButtonTitle];
 
		}
        
        if (otherButtonTitle)
        {
              [self addButtonWithTitle:otherButtonTitle];
        }
        
	 
 
        
        objc_setAssociatedObject(self, "blockCallback", block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return self;
}


- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^block)(NSUInteger buttonIndex) = objc_getAssociatedObject(self, "blockCallback");
    if (block)
    {
        block(buttonIndex);
    }
    
    objc_setAssociatedObject(self, "blockCallback", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
