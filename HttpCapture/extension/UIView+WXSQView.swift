//
//  UIView+WXSQView.swift
//  weixindress
//
//  Created by tianjie on 3/23/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil).first as? UIView
    }
    
    class func autoresizingFlexibleAll() -> UIViewAutoresizing {
        return [UIViewAutoresizing.FlexibleTopMargin,UIViewAutoresizing.FlexibleLeftMargin,UIViewAutoresizing.FlexibleBottomMargin,UIViewAutoresizing.FlexibleRightMargin,UIViewAutoresizing.FlexibleWidth,UIViewAutoresizing.FlexibleHeight]
    }
}
