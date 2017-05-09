//
//  UIView+.swift
//  weixindress
//
//  Created by timothywei on 15/4/3.
//  Copyright (c) 2015年 www.jd.com. All rights reserved. 扩展UIView类
//

import Foundation

private var showScrollToTopContentOffset = "showScrollToTopContentOffset"
private var scrollToTopButtonKey = "scrollToTopButtonKey"
private var viewiewCustomShowStateKey = "UIView.CustomShowState.key"
private var viewiewCustomShowTypeKey = "UIView.CustomShowType.key"
enum UIViewCustomShowState:Int
{
    case showCompelete = 0;
    case inPresentProgress = 1;
    case inDismissProgress = 2;
}

enum UIViewCustomShowType:Int
{
    case Normal = 0;
    case ZTrasition = 1;
}

extension UIView {
    @IBInspectable var extCornerRadius:CGFloat
    {
        get
        {
            return self.layer.cornerRadius
        }
        
        set
        {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var extBorderWidth: CGFloat{
        set
        {
            self.layer.borderWidth = newValue
        }
        
        get
        {
            return  self.layer.borderWidth
        }
    }
    
    @IBInspectable var extBorderColor: UIColor {
        get {
            return  UIColor(CGColor: self.layer.borderColor!)//叹号啊
        }
        set {
            self.layer.borderColor = newValue.CGColor
        }
    }
    
    internal var scrollToTopTag:Int
        {
        get{
            return 20129
        }
    }
    internal var scrollToTopButton:UIButton?
        {
        get {
            if let btn = objc_getAssociatedObject(self, &scrollToTopButtonKey) as? UIButton,let actions = btn.actionsForTarget(self, forControlEvent: UIControlEvents.TouchUpInside) where actions.contains("scrollToTop")
            {
                return btn
            }
            else{
                let btnWidth:CGFloat = 40
                let btnHeight:CGFloat = 40
                let btn = UIButton(frame: CGRectMake(self.width - btnWidth - 10,self.bottom - btnHeight - 40,btnWidth,btnHeight))
                btn.addTarget(self, action: "scrollToTop", forControlEvents: UIControlEvents.TouchUpInside)
                btn.setBackgroundImage(UIImage(named: "top_jiantou"), forState: UIControlState.Normal)
                btn.alpha = 0
                self.addSubview(btn)
                
                self.scrollToTopButton = btn
                
                return btn
            }
        }
        set {
            objc_setAssociatedObject(self, &scrollToTopButtonKey, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    dynamic func scrollToTop(){
        if let vc = self.nextResponder() as? UIViewController where vc.respondsToSelector("scrollToTop")
        {
            vc.performSelector("scrollToTop")
        }
    }
    
//    @IBInspectable var extTransform3D: CATransform3D{
//        set
//        {
//            self.layer.transform = newValue
//        }
//        
//        get
//        { 
//            return  self.layer.transform
//        }
//        
//        
//    }
    
    //  self.animationImageView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI) * 0.5, 0, 0, 1)
    
    class func topLine(superView:UIView,height:CGFloat,color:UIColor)  {
        
        let _topLine:UIView = UIView()
        _topLine.backgroundColor = color
        superView.addSubview(_topLine)
        
        let h:CGFloat = height/WXDevice.scale

        _topLine.translatesAutoresizingMaskIntoConstraints = false
        superView.addConstraint(NSLayoutConstraint(item: _topLine, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        superView.addConstraint(NSLayoutConstraint(item: _topLine, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        _topLine.addConstraint(NSLayoutConstraint(item: _topLine, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: h))
        _topLine.addConstraint(NSLayoutConstraint(item: _topLine, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: WXDevice.width))
        superView.addConstraint(NSLayoutConstraint(item: _topLine, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
    }
    
    class func bottomLine(superView:UIView,height:CGFloat,color:UIColor) {
        let _bottomLine:UIView = UIView()
        _bottomLine.backgroundColor = color
        superView.addSubview(_bottomLine)
        
        _bottomLine.translatesAutoresizingMaskIntoConstraints = false
        superView.addConstraint(NSLayoutConstraint(item: _bottomLine, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        superView.addConstraint(NSLayoutConstraint(item: _bottomLine, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        let h:CGFloat = height/WXDevice.scale
        _bottomLine.addConstraint(NSLayoutConstraint(item: _bottomLine, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: h))
        _bottomLine.addConstraint(NSLayoutConstraint(item: _bottomLine, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: WXDevice.width))
        superView.addConstraint(NSLayoutConstraint(item: _bottomLine, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant:0.0))
    }
    
    
 
    func hidePopView()
    {
        self.removePopView()
    }
    
    
    func setPopState(re:UIViewCustomShowState)
    {
        objc_setAssociatedObject(self, &viewiewCustomShowStateKey,re.hashValue , objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
    
    func popState()->UIViewCustomShowState
    {
        if let re = objc_getAssociatedObject(self, &viewiewCustomShowStateKey) as? Int
        {
            if let r = UIViewCustomShowState(rawValue: re)
            {
                return r
            }
        }
        return UIViewCustomShowState.showCompelete
    }
    
    func setPopType(re:UIViewCustomShowType)
    {
        objc_setAssociatedObject(self, &viewiewCustomShowTypeKey,re.hashValue , objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
    
    func popType()->UIViewCustomShowType
    {
        if let re = objc_getAssociatedObject(self, &viewiewCustomShowTypeKey) as? Int
        {
            if let r = UIViewCustomShowType(rawValue: re)
            {
                return r
            }
        }
        return UIViewCustomShowType.Normal
    }
    
    func handleGes(ges:UIGestureRecognizer)
    {
        
    }
 
    
    func showView(type:UIViewCustomShowType,target:AnyObject? = nil ,selector:String? = nil ,completeBlock:(()->Void)? = nil) {
        
        if self.height > WXDevice.height
        {
            return
        }
//        self.setPopState(UIViewCustomShowState.inPresentProgress)
        self.setPopType(type)
        let backgroundView = UIView(frame: CGRectMake(0.0,0.0,WXDevice.width,WXDevice.height))
        let bgControl = UIControl(frame: CGRectMake(0.0,0.0,WXDevice.width,WXDevice.height - self.height))
        print("\(bgControl) \(bgControl.frame)")
        self.top = WXDevice.height
        backgroundView.addSubview(self)
        backgroundView.addSubview(bgControl)
        if target != nil && selector != nil &&  target!.respondsToSelector(Selector(selector!))
        {
            bgControl.addTarget(target!, action: Selector(selector!), forControlEvents: UIControlEvents.TouchUpInside)
            bgControl.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector(selector!)))
            
        }
        else
        {
            bgControl.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "hidePopView"))
            bgControl.addTarget(self, action: Selector("hidePopView"), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if type == UIViewCustomShowType.ZTrasition {
            backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0)
            if let nav = UIViewController.topViewController()?.navigationController as UINavigationController? {
                if let ve = nav.view.superview {
                    
                    let snapshotView = ve.snapshotViewAfterScreenUpdates(false)
                    snapshotView.frame = ve.bounds
                    
                    let animationbgView = UIView(frame: ve.bounds)
                    animationbgView.backgroundColor = UIColor.blackColor()
                    ve.addSubview(animationbgView)
                    animationbgView.addSubview(snapshotView)
                    animationbgView.addSubview(backgroundView)
               
                    
                    animationbgView.tag = 10300
                    snapshotView.tag = 10301
                    
                    
                    let layer = snapshotView.layer
                    layer.anchorPoint = CGPointMake(0.5, 1.0)
                    snapshotView.frame = snapshotView.bounds
                    if self.layer.shadowRadius != 2.0 {
                        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
                        self.layer.shadowOffset = CGSize(width: 0,height: -2.0)
                        self.layer.shadowRadius = 2.0
                        self.layer.shadowOpacity = 1.0
                    }

                    UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self]() -> Void in
                        if let wself = self {
                            wself.top = WXDevice.height - wself.height
                        }

                        }, completion: { (complete:Bool) -> Void in

                    })

                    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
                        layer.zPosition = -4000
                        var rotationAndPerspectiveTransform:CATransform3D = CATransform3DIdentity
                        rotationAndPerspectiveTransform.m34 = 1.0 / -500.0
                        let angle:CGFloat = CGFloat(5.0 * CGFloat(M_PI / 180.0))
                        layer.transform = CATransform3DRotate(rotationAndPerspectiveTransform, angle, 1.0, 0.0, 0.0)
                        
                        }) {[weak self] (finish:Bool) -> Void in

                            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                                layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0.0, -100, 0.0), 0.8, 0.8, 1.0)
                                }) { (finish:Bool) -> Void in
//                                    self?.setPopState(UIViewCustomShowState.showCompelete)
                                    completeBlock?()
                                    
                            }
                    }
                    
                    return
                }
            }
        }
        else if type == UIViewCustomShowType.Normal {
            if let vc = AppDelegate.sharedApp()?.window {
                
                vc.addSubview(backgroundView)
                
                UIView.animateWithDuration(0.3, animations: { [weak self] () -> Void in
                    self?.superview?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
                    if let wself = self {
                        self?.top = WXDevice.height - wself.height
                    }
                    }) { [weak self](complete:Bool) -> Void in
//                        self?.setPopState(UIViewCustomShowState.showCompelete)
                        completeBlock?()
                }
            }
        }
    }
    
    func removePopView(completeBlock:(()->Void)? = nil) {
 
//        print("someting wrong \(self.popState())")
        
        let type = self.popType()
        
        if type == UIViewCustomShowType.ZTrasition {
            if let nav = UIViewController.topViewController()?.navigationController as UINavigationController? {
                if let ve = nav.view.superview, let bgView = ve.viewWithTag(10300), let snapShotView = bgView.viewWithTag(10301) {
                    
                    let layer = snapShotView.layer
                    
                    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self]() -> Void in
//                        self?.setPopState(UIViewCustomShowState.inDismissProgress)
                        self?.superview?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0)
                        self?.top = WXDevice.height
                        
                        layer.transform = CATransform3DIdentity
                        
                        }) { [weak self](complete:Bool) -> Void in
                            
                        self?.superview?.removeFromSuperview()
                        bgView.removeFromSuperview()
//                        self?.setPopState(UIViewCustomShowState.showCompelete)
                        completeBlock?()
                    }
                }
                else {
                    completeBlock?()
                }
            }
            else {
                completeBlock?()
            }
            
        }
        else  {
            UIView.animateWithDuration(0.3, animations: { [weak self]() -> Void in
                self?.setPopState(UIViewCustomShowState.inDismissProgress)
                self?.top = WXDevice.height
                self?.superview?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0)
                }) { [weak self](complete:Bool) -> Void in
                    self?.superview?.removeFromSuperview()
                    self?.setPopState(UIViewCustomShowState.showCompelete)
                    completeBlock?()
            }
        }
    }
}










