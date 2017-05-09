//
//  ViewHelper.swift
//  weixindress
//
//  Created by timothy-vm-mac on 15-2-2.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class ViewHelper{
    class func getFirstUITabBarController(responder:UIResponder?) -> UITabBarController? {
        var returnResponder:UIResponder? = responder
        while (returnResponder != nil) {
            if returnResponder!.isKindOfClass(UITabBarController) {
                return returnResponder! as? UITabBarController
            }
            
            returnResponder = returnResponder!.nextResponder()
        }
        
        return nil
    }
    
    class func getFirstNavigationControllerContainer(responder:UIResponder?) -> UIViewController? {
        var returnResponder:UIResponder? = responder
        while (returnResponder != nil) {
            if let vc = returnResponder as? UIViewController { // returnResponder?.isKindOfClass(UIViewController) == true {
                
                if vc.navigationController != nil {
                    return vc
                }
            }
            else if returnResponder?.isKindOfClass(UINavigationBar) == true
            {
                // (returnResponder! as UINavigationBar)
                
                
            }
            
            returnResponder = returnResponder!.nextResponder()
        }
        
        return nil
    }
    
    class func timeout_callback(second:Int, completion: (() -> Void)?){
        let delayInSecond:Int64 = Int64(NSEC_PER_SEC.hashValue * second)
        let dispatch_time_value:dispatch_time_t =  dispatch_time(DISPATCH_TIME_NOW,  delayInSecond)
        
        dispatch_after(dispatch_time_value,  dispatch_get_main_queue(), { () -> Void in
            completion!();
        })
    }
    
    class func onGetSuperViewController(view:UIView?) -> UIViewController?{
        if (view != nil)
        {
            for var next:UIView! = view ; (next != nil) ; next = next.superview{
                DPrintln("view nextresponser \(view) \(next.nextResponder())")
                if let nextResponder:UIResponder = next.nextResponder(){
                    if nextResponder.isKindOfClass(UIViewController){
                        return nextResponder as? UIViewController
                    }
                }
            }
        }
        
        return nil
    }
}

