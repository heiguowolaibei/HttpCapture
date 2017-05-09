//
//  WXNetworkStatusManager.swift
//  weixindress
//
//  Created by louyunping on 15/4/16.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

/*   =================================================================
*      网络状态管理类。检测当前网络状态
*   =================================================================
**/

import Foundation


@objc class WXNetworkStatusManager: NSObject {
    
    static var per_second:NSTimeInterval = 30
    static var tipL:UILabel?
    static var timer:NSTimer?
    static let NetworkStatusChangeKey:String = "NetworkStatusChange"
    static var curStatus:AFNetworkReachabilityStatus?
    static var curWWANStatus:WWANType?
    class func startMonitor() {
        let manager:AFNetworkReachabilityManager = AFNetworkReachabilityManager.sharedManager()
        manager.startMonitoring()
        WXNetworkStatusManager.curStatus = manager.networkReachabilityStatus
        WXNetworkStatusManager.curWWANStatus = WWANJudgeHelper.onGetWWANType()
        
        manager.setReachabilityStatusChangeBlock { (status:AFNetworkReachabilityStatus) -> Void in
//            NSLog("当前网络状态 = %i", status.rawValue)
            if  WXNetworkStatusManager.curStatus != status{
                let previousStatus = WXNetworkStatusManager.curStatus?.rawValue
                WXNetworkStatusManager.curStatus = status
                WXNetworkStatusManager.curWWANStatus = WWANJudgeHelper.onGetWWANType()
                NSNotificationCenter.defaultCenter().postNotificationName(WXNetworkStatusManager.NetworkStatusChangeKey, object: nil)
                if previousStatus == -1 { return }
                if let status = WXNetworkStatusManager.curStatus {
                    switch status.rawValue {
                    case 1:
                        var _4G = ""
                        if let wwanStatus = WXNetworkStatusManager.curWWANStatus {
                            switch wwanStatus.rawValue {
                            case 1:
                                _4G = "2G"
                            case 2:
                                _4G = "3G"
                            case 3:
                                _4G = "4G"
                            default:
                                _4G = ""
                            }
                        }
                        MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("切换到\(_4G)移动网络")
                    case 2:
                        MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("切换到WiFi网络")
                    default:
                        MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("似乎与网络断开连接")
                    }
                }
                
            }
            
//            if status == AFNetworkReachabilityStatus.NotReachable {
//                self.setupTimer()
//            }
            
        }
//        SimplePingHelper.ignorePIPE()
//        self.setupTimer()
    }
    
    class func setupTimer() {
//        self.startOnline()
//        self.timer?.invalidate()
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.per_second, target: self, selector: Selector("startOnline"), userInfo: nil, repeats: true)
    }
    
    class func startOnline() {
//        SimplePingHelper.ping("114.114.114.114", target: self, sel: Selector("pingResult:"))
    }
    
    class func pingResult(success:NSNumber) {
        
        WXDevice.isOnline = success.boolValue
        if success.boolValue {

            if self.per_second == 5 {
                
                self.per_second = 30
                self.setupTimer()
            }
        }
        else {

            if self.per_second == 30 {
                
                self.per_second = 5

                self.setupTimer()
            }
        }
//        self.showNetworkTip()
    }
    
    class func currentNetworkType() -> String {
        
        var networkStatus:String = ""
        if WXNetworkStatusManager.curStatus == AFNetworkReachabilityStatus.ReachableViaWiFi{
            networkStatus = "WIFI"
        }
        if WXNetworkStatusManager.curStatus == AFNetworkReachabilityStatus.ReachableViaWWAN{
            if WXNetworkStatusManager.curWWANStatus == WWANType.is2G{
                networkStatus = "2G"
            }
            if WXNetworkStatusManager.curWWANStatus == WWANType.is3G{
                networkStatus = "3G"
            }
            if WXNetworkStatusManager.curWWANStatus == WWANType.is4G{
                networkStatus = "4G"
            }
            if WXNetworkStatusManager.curWWANStatus == WWANType.isXG{
                networkStatus = "XG"
            }
        }
        if WXNetworkStatusManager.curStatus == AFNetworkReachabilityStatus.NotReachable{
            networkStatus = "NONE"
        }
        if WXNetworkStatusManager.curStatus == AFNetworkReachabilityStatus.Unknown{
            networkStatus = "UNKNOW"
        }
        
        return networkStatus
    }
    
    class func showNetworkTip() {
        
        if !WXDevice.isOnline {
            if self.tipL != nil && self.tipL?.top == 0 {
                return
            }
            let l = UILabel(frame: CGRectMake(0, -30, WXDevice.width, 30))
            l.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4)
            l.textColor = UIColor.CustomRed()
            l.textAlignment = .Center
            l.font = UIFont.boldSystemFontOfSize(12.0)
            l.text = "当前网络出现故障，请检查重新连接"
            if let app = AppDelegate.sharedApp() {
                app.window?.addSubview(l)
            }
            
            self.tipL = l

            UIView.animateWithDuration(0.2, animations: { () -> Void in
                l.top = 0
            })
        }
        else {
            if self.tipL == nil || self.tipL?.top == -30 {
                return
            }
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.tipL?.top = -30
            })

        }
    }
    
    
}
