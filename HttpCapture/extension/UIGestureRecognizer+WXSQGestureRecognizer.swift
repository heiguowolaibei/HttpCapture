//
//  UIGestureRecognizer+WXSQGestureRecognizer.swift
//  weixindress
//
//  Created by tianjie on 3/31/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation

private var scrollToLeftKey = "scrollToLeftKey"

extension UIGestureRecognizer {
    @objc internal var scrollToLeft: Bool {
        get {
            if let p = objc_getAssociatedObject(self, &scrollToLeftKey) as? NSNumber {
                return p.boolValue
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &scrollToLeftKey, NSNumber(bool: newValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func end() {
        let currentStatus = self.enabled
        self.enabled = false
        self.enabled = currentStatus
    }
    
    func hasRecognizedValidGesture() -> Bool {
        return self.state == UIGestureRecognizerState.Changed || self.state == UIGestureRecognizerState.Began
    }

}