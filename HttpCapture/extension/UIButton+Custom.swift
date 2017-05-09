//
//  sdfsdf.swift
//  weixindress
//
//  Created by 杨帆 on 15/7/14.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import UIKit

extension UIButton
{
    private struct AssociatedKeys {
        static var originText:NSNumber?
    }
    
    public var originText:String? {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.originText) as? String {
                return value
            }
            return self.titleLabel?.text
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.originText, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class func  customRedButton(frame:CGRect,text:String,textSize:CGFloat) -> UIButton
    {
        let redButton = UIButton(frame:frame)
 
        redButton.setTitle(text,forState: UIControlState.Normal)
        redButton.backgroundColor = UIColor.CustomRed();
        redButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        redButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        redButton.layer.cornerRadius = 3;
        redButton.titleLabel!.font = UIFont.systemFontOfSize(textSize)
        
        return redButton;
    }
    
    
    class func  customBlackButton(frame:CGRect,text:String,textSize:CGFloat) -> UIButton
    {
        let blackButton = UIButton(frame:frame)
        
        blackButton.setTitle(text, forState: UIControlState.Normal)
        blackButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        blackButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        blackButton.layer.cornerRadius = 3;
        blackButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        blackButton.layer.borderWidth = 0.5
        blackButton.titleLabel!.font = UIFont.systemFontOfSize(textSize)
        
        return blackButton;
    }
    
}
