//
//  UIViewController+TipMsg.swift
//
//  UIViewController 弹出消息
//
//  Created by timothywei on 15/4/22.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation
import UIKit

// 消息样式
enum UIViewControllerTipStyle:Int {
    case Insert = 0 // 在 ViewController View 插入
    case Flow = 1 // 浮在  ViewController View 上
}


extension UIViewController {
    
    func showTip(viewController:UIViewController?, view:UIView?, height:CGFloat, tipStyle:UIViewControllerTipStyle = UIViewControllerTipStyle.Flow, autoClose:Bool = true, closeDelayTime: NSTimeInterval = 2.0, durationTime: NSTimeInterval = 0.25) -> Void {
        
        if let vc = viewController {
            self.addChildViewController(vc)
        }
        
        
        if let v = view {
            if self.view.superview == nil {
                self.view.addSubview(v)
            }
            else {
                self.view.superview?.addSubview(v)
            }
            
            let vcViewFrame = self.view.frame
            
            
            v.frame = CGRect(x: vcViewFrame.minX, y: vcViewFrame.minY - height, width: vcViewFrame.width, height: height)
            
            UIView.animateWithDuration(durationTime, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                if tipStyle == UIViewControllerTipStyle.Insert {
                    self.view.frame = CGRect(x: vcViewFrame.minX, y: vcViewFrame.minY  + height, width: vcViewFrame.width, height: vcViewFrame.height - height)
                }
                
                v.frame = CGRect(x: vcViewFrame.minX, y: vcViewFrame.minY + 64, width: vcViewFrame.width, height: height)
                
                }) {
                    (b:Bool) -> Void in
                    
                    if autoClose {
                        self.closeTip(viewController, view: view, height: height, tipStyle: tipStyle, closeDelayTime: closeDelayTime, durationTime: durationTime)
                    }
            }
        }
    }
    
    func closeTip(viewController:UIViewController?, view:UIView?, height:CGFloat, tipStyle:UIViewControllerTipStyle = UIViewControllerTipStyle.Flow, closeDelayTime: NSTimeInterval = 2.0, durationTime: NSTimeInterval = 0.25){
        if let v = view {
            
            let vcViewFrame = self.view.frame
            
            
            UIView.animateWithDuration(durationTime, delay: closeDelayTime, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                if tipStyle == UIViewControllerTipStyle.Insert {
                    self.view.frame = CGRect(x: vcViewFrame.minX, y: vcViewFrame.minY - height, width: vcViewFrame.width, height: vcViewFrame.height + height)
                }
                
                v.frame = CGRect(x: vcViewFrame.minX, y: vcViewFrame.minY - height - height , width: vcViewFrame.width, height: height)
                
                }) {
                    (b:Bool) -> Void in
                    
                    if let vc = viewController {
                        vc.removeFromParentViewController()
                    }
                    
                    if let v = view {
                        v.removeFromSuperview()
                    }
            }
        }
    }
}
