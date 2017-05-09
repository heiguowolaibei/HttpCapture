//
//  CommonImageCache.swift
//  weixindress
//
//  Created by 杜永超 on 15/11/6.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

import UIKit

class CommonImageCache: NSObject {
    
    static var publishCollocationIcon_normal:UIImage?
    static var singleShopIcon_normal:UIImage?
    static var likeCollocationIcon_normal:UIImage?
    static var contentIcon_normal:UIImage?
    static var publishCollocationIcon_selected:UIImage?
    static var singleShopIcon_selected:UIImage?
    static var likeCollocationIcon_selected:UIImage?
    static var contentIcon_selected:UIImage?

    lazy private var imageCache = [String:UIImage]()
    
    static let sharedInstance = CommonImageCache()
    
    private var myQ:dispatch_queue_t?
    lazy private var myReadQ:dispatch_queue_t = dispatch_queue_create("CommonImageCache.read", DISPATCH_QUEUE_CONCURRENT)
    
    /// 需要预缓存的图片 需要多次复用(tableViewCell)的图片都可以加入
    let preloadImageNameArr = ["登录头像","登录头像-圆形","icon_7days_black","icon_7days_grey","达人星","搭配见习生","助理搭配师","初级搭配师","中级搭配师","高级搭配师","资深搭配师","logo_jzyc","logo_jd","icon_more","icon_choice","icon_shop_normal","icon_collect","icon_collect_yellow","icon_hint","icon_right_circle2","feed_square_golook_alltopic","feed_like_dapei","心形","icon_switch_grey","icon_switch_red"]
    
    override init() {
        super.init()
        myQ = dispatch_queue_create("CommonImageCache.init", DISPATCH_QUEUE_CONCURRENT)
        guard let q = myQ else {return}
        if #available(iOS 9.0, *) {

            dispatch_async(q) { () -> Void in
                
                var dic = [String:UIImage]()
                for name in self.preloadImageNameArr {
                    let tmpImg = UIImage(named: name)
                    dic[name] = tmpImg
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageCache.update(dic)
                    self.myQ = nil
                })
                
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didReceiveMemoryWarning:"), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    func didReceiveMemoryWarning(noti:NSNotification) {
        self.imageCache.removeAll()
    }
    /// 缓存图片
    /// * iOS9以下会同步等待预加载图片
    /// * 子线程调用可以使用
    /**
        getImage(named name:String?, completion:((image:UIImage?) -> Void)?)
     */

    class func getImage(named name:String?) -> UIImage? {
        return CommonImageCache.sharedInstance.getImage(named: name)
    }
    
    class func getImage(named name:String, completion:((image:UIImage?) -> Void)?)    {
        CommonImageCache.sharedInstance.getImage(named: name, completion: completion)
    }
    
    /// 会统一在myReadQ读取并在主线程回调
    func getImage(named name:String, completion:((image:UIImage?) -> Void)?) {
        let i = CommonImageCache.sharedInstance.getImage(named: name)
        completion?(image:i)
        
    }
    
//    func getImgaeForMemoryCache(name:String) -> UIImage?
//    {
//        if let img = self.imageCache[name]
//        {
//            return img
//        }
//        return nil
//    }
//    
//    func setImageForMemoryCache(image:UIImage,name:String)
//    {
//        self.imageCache[name] = image
//    }
    
    
    
    
    /*!
     http://stackoverflow.com/questions/34022891/live-app-crash-on-uiimage-imagenamed
     In iOS 9 and later, this method([UIImage imageNamed:]) is thread safe.
     但在iOS9之前 多个子线程调用UIImage(named:)同一个图片会有一定概率crash
     */
    
    private func getImage(named name:String?) -> UIImage? {
        guard let imageName = name else {return nil}

        if self.myQ != nil {
            dispatch_sync(myQ!, {
            })
        }
        if let img = self.imageCache[imageName] {
            return img
        }else {
            let tmpImg = UIImage(named: imageName)
            self.imageCache[imageName] = tmpImg
            return tmpImg
        }
    }
    
/**
     获取头像右下角会员等级标志
*/
    func getLevelImage(level_id:Int) -> UIImage {
        switch level_id {
        case 1:
            
            let levelImg1 = getImage(named:"icon_vip1")
            return levelImg1!
            
        case 2:
            
            let levelImg2 = getImage(named:"icon_vip2")
            return levelImg2!
            
        case 3:
            
            let levelImg3 = getImage(named:"icon_vip3")
            return levelImg3!
            
        case 4:
            
            let levelImg4 = getImage(named:"icon_vip4")
            return levelImg4!
            
        case 5:
            
            let levelImg5 = getImage(named:"icon_vip5")
            return levelImg5!
            
        default:
            
            let levelImg1 = getImage(named:"icon_vip1")
            return levelImg1!
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
