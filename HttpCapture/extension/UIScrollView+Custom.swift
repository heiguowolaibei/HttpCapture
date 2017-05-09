//
//  UIScrollView+Custom.swift
//  weixindress
//
//  Created by 杨帆 on 16/2/22.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

import Foundation

enum ScrollTowardType:Int32{
    case notScroll = 0,             //此时无滚动
    ScrollToBottom = 1,             //向下滚动，手指向上
    ScrollToTop = 2,
    ScrollToLeft = 3,
    ScrollToRight = 4
}

private var preContentOffsetKey = "preContentOffsetKey"
private var towardTypeKey = "towardTypeKey"
private var isAddedObserver = "isAddedObserver"


extension UIScrollView
{
    internal var preContentOffset: CGPoint {
        get {
            if let p = objc_getAssociatedObject(self, &preContentOffsetKey) as? String {
                return CGPointFromString(p)
            }
            return CGPointZero
        }
        set {
            objc_setAssociatedObject(self, &preContentOffsetKey, NSStringFromCGPoint(newValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var towardType: ScrollTowardType {
        get {
            if let p = objc_getAssociatedObject(self, &towardTypeKey) as? NSNumber,let type = ScrollTowardType(rawValue: p.intValue)
            {
                return type
            }
            return ScrollTowardType.notScroll
        }
        set {
            objc_setAssociatedObject(self, &towardTypeKey, NSNumber(int: newValue.rawValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func judgeScrollToward(){
        //只考虑单一方向滚动的情况。
        let offset:CGFloat = CGFloat(FLT_EPSILON)
        if fabs(self.contentOffset.y - self.preContentOffset.y) < offset && fabs(self.contentOffset.x - self.preContentOffset.x) < offset
        {
            towardType = .notScroll
        }
        else if fabs(self.contentOffset.y - self.preContentOffset.y) < offset
        {
            if self.preContentOffset.x < self.contentOffset.x{
                towardType = .ScrollToRight
            }
            else {
                towardType = .ScrollToLeft
            }
        }
        else if fabs(self.contentOffset.x - self.preContentOffset.x) < offset
        {
            if self.preContentOffset.y < self.contentOffset.y{
                towardType = .ScrollToBottom
            }
            else {
                towardType = .ScrollToTop
            }
        }
        
//        DPrintln("contentoffsets towardType \(NSStringFromCGPoint(self.preContentOffset));\(self.contentOffset);\(towardType)")
        
        preContentOffset = self.contentOffset
    }
    
    func killScroll()
    {
        var offset = self.contentOffset;
        offset.x -= 1.0;
        offset.y -= 1.0;
        self.setContentOffset(offset, animated: false)
        offset.x += 1.0;
        offset.y += 1.0;
        self.setContentOffset(offset, animated: false)

    }
    
    internal var isAddObserver: Bool {
        get {
            if let p = objc_getAssociatedObject(self, &isAddedObserver) as? Bool {
                return p
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &isAddedObserver, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}