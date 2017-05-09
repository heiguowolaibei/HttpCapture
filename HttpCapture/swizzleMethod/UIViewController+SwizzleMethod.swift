//
//  UIViewController+SwizzleMethod.swift
//  weixindress
//
//  Created by 杨帆 on 15/12/21.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

import Foundation


extension UIViewController
{
    public func wq_presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    {
        var needSlow = false
        if self.isBeingPresented() == true || self.isBeingDismissed() == true {
            needSlow = true
        }
        if let nav = self.navigationController
        {
            if nav.isBeingPresented() == true || nav.isBeingDismissed() == true {
                needSlow = true
            }
        }
        
        if let nv =  self.navigationController where nv is BaseNavigationController
        {
            let baseNv = nv as! BaseNavigationController
            if baseNv.isTransitioning || baseNv.isPanning
            {
                needSlow = true
            }
        }

        if needSlow
        {
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(Float(NSEC_PER_SEC) * 0.2))
            dispatch_after(popTime, dispatch_get_main_queue(), {
                () ->Void in
                self.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
            })

        }
        else
        {
            self.wq_presentViewController(viewControllerToPresent, animated: flag, completion: completion)

        }
    }
    
    @objc public func wq_viewWillAppear(animated:Bool){
        MBProgressHUDHelper.sharedMBProgressHUDHelper.roateViewStartAnimation()
        self.wq_viewWillAppear(animated)
    }
}
