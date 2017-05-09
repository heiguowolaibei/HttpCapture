//
//  CaptureBaseViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/12.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import Foundation
import UIKit

@objc class CaptureBaseViewController: UIViewController,UINavigationControllerDelegate,SideBarItemDelegate {
    private var backBarButtonItem:UIBarButtonItem? = nil
    
    @objc var leftBtn: UIButton = NavigationButton()
    var rightBtn: UIButton = NavigationRightButton()
    
    var _gestureEnabled:Bool = false
    var _isShowTipView:Bool = false
    var _isShowButton:Bool = false
    
    var _tipText:String = ""
    var _tipImageName:String = ""
    
    var refreshDataBlock:((Bool,Bool)->Void)?
    
    weak var sidebarDelegate:SideBarItemDelegate?
    
    deinit {
        DPrintln("[\(self)]function:\(__FUNCTION__)")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTabbarItem()
    }
    
    override func hasCustomNavigationBar() -> Bool
    {
        return true
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return false
    }
    
    func initTabbarItem() {
        if self.useDefaultBackButton(){
            leftBtn.frame = CGRectMake(0, 0, 44, 44)
            
            if self.navigationController?.viewControllers.count > 1
            {
                leftBtn.setImage(CommonImageCache.getImage(named: "返回"), forState: UIControlState.Normal)
                leftBtn.setImage(CommonImageCache.getImage(named: "返回-按下"), forState: UIControlState.Highlighted)
            }
            else
            {
                leftBtn.setImage(CommonImageCache.getImage(named: "关闭"), forState: UIControlState.Normal)
                leftBtn.setImage(CommonImageCache.getImage(named: "关闭"), forState: UIControlState.Highlighted)
            }
            
            leftBtn.addTarget(self, action: "leftButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            leftBtn.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
            leftBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
            
            
            let leftItem = UIBarButtonItem(customView: leftBtn)
            //self.navigationItem.hidesBackButton = true;
            self.navigationItem.leftBarButtonItem = leftItem
            
            rightBtn.frame = CGRectMake(0, 0, 44, 44)
            rightBtn.contentHorizontalAlignment = .Right
            rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
            rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
            rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
            rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
            rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
            rightBtn.setImage(CommonImageCache.getImage(named: "btn_common_black_back"), forState: UIControlState.Normal)
            rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let rightItem = UIBarButtonItem(customView: rightBtn)
            self.navigationItem.rightBarButtonItem = rightItem
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setRightButtons(ds:[(UIImage,UIImage,String)])
    {
        var arr = [UIBarButtonItem]()
        
        for (index,d) in ds.enumerate()
        {
            let btn = UIRightButton()
            let btnWidth:CGFloat = 44
            
            btn.normalFrame = CGRectMake(WXDevice.width - CGFloat((ds.count - index)) * btnWidth, 20, btnWidth, btnWidth)
            btn.frame = CGRectMake(0, 0, 44, 44)
            btn.contentHorizontalAlignment = .Center
            if index == 1 {
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3)
                btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3)
            }else {
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 0)
                btn.contentEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 0)
            }
            
            btn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
            btn.contentMode = UIViewContentMode.ScaleAspectFit;
            btn.tag = index;
            btn.setImage(d.0, forState: UIControlState.Normal)
            btn.setImage(d.1, forState: UIControlState.Highlighted)
            btn.addTarget(self, action: Selector(d.2), forControlEvents: UIControlEvents.TouchUpInside)
            let rightItem = UIBarButtonItem(customView:btn)
            arr.append(rightItem)
        }
        self.navigationItem.rightBarButtonItems = arr
    }
    
    func setLeftTitle(string:String)
    {
        leftBtn.setTitle(string, forState: UIControlState.Normal)
        self.leftBtn.setImage(nil, forState: UIControlState.Normal)
        self.leftBtn.setImage(nil, forState: UIControlState.Highlighted)
        leftBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        leftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        leftBtn.contentHorizontalAlignment = .Left
        if let _ = rightBtn.titleLabel
        {
            let size = (string as NSString).sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(14)])
            leftBtn.frame = CGRectMake(0, 0, size.width+20, size.height+20)
        }
        
    }
    
    func setRightTitle(string:String)
    {
        rightBtn.setTitle(string, forState: UIControlState.Normal)
        
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        if let _ = rightBtn.titleLabel
        {
            let size = (string as NSString).sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(14)])
            rightBtn.frame = CGRectMake(0, 0, size.width+20, size.height+20)
        }
    }
    
    func useDefaultBackButton() -> Bool{
        return true;
    }
    
    @objc func configLeftBtn()  {
        self.navigationBar.viewWithTag(1000)?.removeFromSuperview()
        if self.navigationBar.viewWithTag(1002) == nil {
            leftBtn.frame = CGRectMake(0, 20, 44, 44)
            leftBtn.tag = 1002
            if self.navigationController?.viewControllers.count > 1
            {
                leftBtn.setImage(CommonImageCache.getImage(named: "返回"), forState: UIControlState.Normal)
                leftBtn.setImage(CommonImageCache.getImage(named: "返回-按下"), forState: UIControlState.Highlighted)
            }
            else
            {
                leftBtn.setImage(CommonImageCache.getImage(named: "关闭"), forState: UIControlState.Normal)
                leftBtn.setImage(CommonImageCache.getImage(named: "关闭"), forState: UIControlState.Highlighted)
            }
            
            leftBtn.addTarget(self, action: "leftButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            leftBtn.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
            leftBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
            
            self.navigationBar.addSubview(leftBtn)
        }
    }
    
    func hideleftBackButton(re:Bool) {
        leftBtn.hidden = re;
    }
    
    func hideRightButton(re:Bool) {
        rightBtn.hidden = re;
    }
    
    func leftButtonClick(item:UIButton) {
        if self.navigationController?.viewControllers.count > 1
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
        else
        {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    func rightButtonClick(item:UIButton) {
    }
    
    func willPop()
    {
    }
    
}

