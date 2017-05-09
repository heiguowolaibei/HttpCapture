//
//  UIColor+RGB.swift
//  weixindress
//
//  Created by timothywei on 15/4/15.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    @objc class func fromRGBA(rgba:UInt32) -> UIColor {
        
        let r:CGFloat = (CGFloat((rgba & 0xFF000000) >> 24))/255.0
        let g:CGFloat = (CGFloat((rgba & 0x00FF0000) >> 16))/255.0
        let b:CGFloat = (CGFloat((rgba & 0x0000FF00) >> 8))/255.0
        let a:CGFloat = (CGFloat((rgba & 0x000000FF) >> 0))/255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    @objc class func fromRGB(rgba:UInt32) -> UIColor {
        
        let r:CGFloat = (CGFloat((rgba & 0xFF0000) >> 16))/255.0
        let g:CGFloat = (CGFloat((rgba & 0x00FF00) >> 8))/255.0
        let b:CGFloat = CGFloat((rgba & 0x0000FF))/255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    
    class func CustomRed() -> UIColor {
        return self.fromRGBA(0xe11644ff);
    }
    
    class func customTextColor() -> UIColor {
        return self.fromRGBA(0x333333ff);
    }
    
    class func customSubTextColor() -> UIColor {
        return self.fromRGBA(0x999999ff);
    }
    
    class func customCCCTextColor() -> UIColor {
        return self.fromRGBA(0xccccccff);
    }
    
    class func customBackgroundColor() -> UIColor {
        return self.fromRGBA(0xEEEEEEFF);
    }
}