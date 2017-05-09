//
//  UIColor+WXSQColor.swift
//  weixindress
//
//  Created by tianjie on 3/26/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func colorWithRGB(red red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0 ) -> UIColor {
        return UIColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha)
    }
}