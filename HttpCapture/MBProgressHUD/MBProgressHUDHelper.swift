//
//  MBProgressHUDHelper.swift
//  weixindress
//
//  Created by tianjie on 3/21/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation

public class MBProgressHUDHelper: NSObject, MBProgressHUDDelegate {
    private struct Inner {
        static let defaultDuration: NSTimeInterval = 1.8
    }
    
    var hud: MBProgressHUD?
    private override init() {
        super.init()
    }
    
    public class var sharedMBProgressHUDHelper: MBProgressHUDHelper {
        struct Singleton {
            static let sharedMBProgressHUDHelper = MBProgressHUDHelper()
        }
        
        return Singleton.sharedMBProgressHUDHelper
    }
    
    public func roateViewStartAnimation(){
        
    }
    
    public func showText(text: String) {
        self.showText(text, delayTime: Inner.defaultDuration)
    }
    
    public func showText(text: String, delayTime time: NSTimeInterval) -> MBProgressHUD {
        let defaultParentView = getDefaultParentView()
        return self.showText(text, delayTime: time, toView: defaultParentView)
    }
    
    public func showLoadingWithCusView(cusView:UIView,superView:UIView? = nil,bUserInteractionEnabed:Bool? = false) -> MBProgressHUD
    {
        hudWasHidden(nil,superView:superView)

        if superView != nil{
            self.hidden(superView!, animation: false)
            hud = MBProgressHUD.showHUDAddedTo(superView!, animated: true)
        }
        else{
            let view = getDefaultParentView()
            hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        }
        hud!.mode = MBProgressHUDMode.CustomView
        hud!.userInteractionEnabled = bUserInteractionEnabed!
        hud!.margin = 10.0
        hud!.cornerRadius = 5.0
        hud!.removeFromSuperViewOnHide = true
        hud!.customView = cusView
        
        return hud!
    }
    
    public func showText(text: String, delayTime time: NSTimeInterval = Inner.defaultDuration, toView view: UIView) -> MBProgressHUD
    {
        hudWasHidden(nil,superView:view)

        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud!.mode = .Text
        //为了支持多行显示，使用detailsLabel
        hud!.detailsLabelFont = UIFont.systemFontOfSize(16)
        hud!.detailsLabelText = text
        hud!.margin = 20.0
        hud!.cornerRadius = 5.0
        hud!.removeFromSuperViewOnHide = true
        hud!.userInteractionEnabled = false
        hud!.hide(true, afterDelay: time)
        
        return hud!
    }
    
    public func showAnimated(animated: Bool, whileExecutingBlock block: dispatch_block_t) {
        hudWasHidden(nil)

        let defaultParentView = getDefaultParentView()
        
        hud = MBProgressHUD.showHUDAddedTo(defaultParentView, animated: true)
        hud!.delegate = self
        hud!.showAnimated(animated, whileExecutingBlock: block)
    }
    
    
    public func showAnimated(animated: Bool, text:String ,whileExecutingBlock block: dispatch_block_t) {
        hudWasHidden(nil)

        let defaultParentView = getDefaultParentView()
        hud = MBProgressHUD.showHUDAddedTo(defaultParentView, animated: true)
        hud?.detailsLabelFont = UIFont.systemFontOfSize(15)
        hud?.detailsLabelText = text
        hud?.delegate = self
        hud?.showAnimated(animated, whileExecutingBlock: block)
    }
    
    public func showAnimated(animated: Bool, text:String )
    {
        hudWasHidden(nil)
        
        let defaultParentView = getDefaultParentView()
        hud = MBProgressHUD.showHUDAddedTo(defaultParentView, animated: true)
        hud?.detailsLabelFont = UIFont.systemFontOfSize(15)
        hud?.detailsLabelText = text
        hud?.delegate = self
        hud?.mode = MBProgressHUDMode.Indeterminate
    }
    
    // MARK: - MBProgressHUDDelegate
    public func hudWasHidden(hud: MBProgressHUD?,superView:UIView? = nil) {
        self.hud?.removeFromSuperview()
        self.hud = nil
        self.hidden(nil, animation: false)
        
        if let vi = superView
        {
            self.hidden(vi, animation: false)
        }
    }

    private func getDefaultParentView() -> UIView! {
        let delegate = AppDelegate.sharedApp() //UIApplication.sharedApplication().delegate
        return delegate?.window!
    }
    
    public func showText(view:UIView?,text:String,animation:Bool) {
        hudWasHidden(nil,superView:view)

        var proHud:MBProgressHUD
        if  view == nil {
            proHud =  MBProgressHUD.showHUDAddedTo(getDefaultParentView(), animated: animation)
        }
        else {
            proHud =  MBProgressHUD.showHUDAddedTo(view!, animated: animation)

        }
        proHud.labelFont = UIFont.systemFontOfSize(15.0)
        proHud.labelText = text
    }
    
    public func hidden(view:UIView?,animation:Bool) {
        if  view == nil {
            MBProgressHUD.hideAllHUDsForView(getDefaultParentView(), animated: animation)
        }
        else {
            MBProgressHUD.hideAllHUDsForView(view, animated: animation)
        }
    }
    
    public func hidden(view:UIView?,text:String,afterDelay:NSTimeInterval,animation:Bool) {
//        if  view == nil {
//            MBProgressHUD.hideAllHUDsForView(getDefaultParentView(), animated: animation)
//        }
//        else {
//            MBProgressHUD.hideAllHUDsForView(view, animated: animation)
//        }
//        NSThread.sleepForTimeInterval(1.0)
        self.showText(text, delayTime: afterDelay)
    }

}