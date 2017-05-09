//
//  UIApplication+WXSQApplication.swift
//  weixindress
//
//  Created by tianjie on 2/27/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    //      static var isDevVersion:Bool = true
    //      static var devVersion:String = "1.01"
    
    public class func getIsDevVersion() -> Bool {
        return false
    }
    
    public class func getDevVersion() -> String {
        return "1.04"
    }
    
    public class func getDeviceId() -> String {
        return  UIDevice.currentDevice().identifierForVendor!.UUIDString.stringByReplacingOccurrencesOfString("-", withString: "") //叹号啊
    }
    
    public class func systemVersion() -> String {
        return UIDevice.currentDevice().systemVersion
    }
    
    public class func appShortVersion() -> String {
        var appShortVersion: String = ""
        if let infoDict = NSBundle.mainBundle().infoDictionary {
            if let shortVersionString = infoDict["CFBundleShortVersionString"] as? String {
                appShortVersion = shortVersionString
            }
        }
        
        return appShortVersion
    }
    
    public class func appBundleVersion() -> String {
        var appBundleVersion: String = ""
        if let infoDict = NSBundle.mainBundle().infoDictionary {
            if let bundleVersion = infoDict["CFBundleVersion"] as? String {
                appBundleVersion = bundleVersion
            }
        }
        return appBundleVersion
    }
    
    public class func getAppLaunchCount() -> Int {
        let key:String = AppConfiguration.Defaults.appLaunchCountKey + UIApplication.appBundleVersion()
        let appLaunchCount:Int = NSUserDefaults.standardUserDefaults().integerForKey(key)
        return appLaunchCount
    }
    
    public class func updateAppLaunchCount() {
        let key:String = AppConfiguration.Defaults.appLaunchCountKey + UIApplication.appBundleVersion()
        var appLaunchCount:Int = NSUserDefaults.standardUserDefaults().integerForKey(key)
        appLaunchCount =  appLaunchCount + 1
        
        NSUserDefaults.standardUserDefaults().setInteger(appLaunchCount, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public class func appIdentifier() -> String {
        var appIdentifier: String = ""
        if let infoDict = NSBundle.mainBundle().infoDictionary {
            if let bundleIdentifier = infoDict["CFBundleIdentifier"] as? String {
                appIdentifier = bundleIdentifier
            }
        }
        
        return appIdentifier
    }
    
    public class func openAppStore() -> Void {
//                var ver:NSString = UIDevice.currentDevice().systemVersion
                UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/cn/app/jing-zhi-yi-chu/id995205628?mt=8")!)
//                if ver.floatValue < 8.0 {
//                    UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id\(appId)")!)
//                }
//                else {
//                    UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appId)")!)
//                }
    }
    
    // 初始化配置Appearance
    dynamic class func configAppearance() {
        
        // tabbar style
//        UITabBar.appearance().tintColor =  UIColor.fromRGBA(0xEC083DFF)
//        UITabBar.appearance().barTintColor = UIColor.fromRGBA(0x78797BFF)
//        UITabBar.appearance().selectedImageTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        UITabBar.appearance().backgroundImage =  UIImage.imageWithColor(UIColor.whiteColor())
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.fromRGBA(0x78797BFF),
//            NSBackgroundColorAttributeName:UIColor.whiteColor()]
//            , forState: UIControlState.Normal)
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.fromRGBA(0xEC083DFF),
//            NSBackgroundColorAttributeName:UIColor.whiteColor()]
//            , forState: UIControlState.Selected)

//        if WXDevice.IOS_VERSION >= 8.0 {
//            UITabBar.appearance().opaque = true
//            UITabBar.appearance().translucent = false
//        }
        
        //        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor(),
        //            NSBackgroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 12.0)!]
        //            , forState: UIControlState.Normal)
        
        
        
        // UITextAttributeFont
//        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor(),
//            NSBackgroundColorAttributeName: UIColor(red: 17.0/255.0, green: 17.0/255.0, blue: 17.0/255.0, alpha: 1)]
//            , forState: UIControlState.Normal)
        
        // navigationbar style
//        UINavigationBar.appearance().backgroundColor = UIColor(red: 17.0/255.0, green: 17.0/255.0, blue: 17.0/255.0, alpha: 1)
//        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor.blackColor()) , forBarMetrics: UIBarMetrics.Default)
//        UINavigationBar.appearance().tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        UINavigationBar.appearance().barTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        UINavigationBar.appearance().titleTextAttributes =  [NSForegroundColorAttributeName:UIColor.whiteColor(), NSBackgroundColorAttributeName:UIColor.blackColor()]
//        
//        UIBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor(),
//            NSBackgroundColorAttributeName:UIColor.whiteColor()] , forState: UIControlState.Normal)
        //status style
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

    
}