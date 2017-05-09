//
//  extention.swift
//  weixindress
//
//  Created by liuyihao1216 on 16/4/7.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView
{
    private struct AssociatedKeys {
        static var selected:NSNumber?
        static var selectedImg:NSNumber?
        static var normalImg:NSNumber?
    }
    
    public var selected:Bool {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.selected) as? NSNumber {
                return value.boolValue
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.selected, NSNumber(bool: newValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var selectedImg:UIImage? {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.selectedImg) as? UIImage {
                return value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.selectedImg, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var normalImg:UIImage? {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.normalImg) as? UIImage {
                return value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.normalImg, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


