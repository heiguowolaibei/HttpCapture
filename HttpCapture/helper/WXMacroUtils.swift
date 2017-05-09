//
//  WXMacroUtils.swift
//  weixindress
//
//  Created by louyunping on 15/4/2.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

// 设备基本信息管理类

import UIKit
import AdSupport

struct WXDevice {
    static var width:CGFloat = UIScreen.mainScreen().bounds.size.width
    static var height:CGFloat = UIScreen.mainScreen().bounds.size.height
    static var scale:CGFloat = UIScreen.mainScreen().scale
    static var IOS_VERSION:Float = (UIDevice.currentDevice().systemVersion as NSString).floatValue  // 操作系统版本
    static var deviceId:NSString = WXSQDeviceInfoUtil.uuidForDevice() // UIDevice.currentDevice().identifierForVendor.UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")  // 设备唯一标识符
    static var idfa:String = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString    //唯一广告标识符
    static var network_speed:Int = -2   // 当前的网速，通过jsapi返回给前端
    static var isOnline:Bool = true     // 当前网络是否连通，通过jsapi返回给前端
    static var devicePlat:NSInteger = UIDevice.currentDevice().platformType()
    static let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    static let shortVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? ""
}

 func KWXShowAlertView(title:String?,msg:String?,delegate:AnyObject?,cancel:String?,other:String?) {
    let alertView:UIAlertView = UIAlertView(title: title, message: msg, delegate: delegate, cancelButtonTitle: cancel)
    if  other?.isEmpty == false {
        alertView.addButtonWithTitle(other!)
    }
    alertView.show()
}

func DPrintln(items: Any...) {
#if DEBUG
    print(items,terminator:"\n")
#endif
}
