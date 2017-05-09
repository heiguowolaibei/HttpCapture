//
//  AppDelegate.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/12.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var viewController:UIViewController?
    var mainController:SidebarMenuViewController?
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        NSURLProtocol.registerClass(OCDHTTPWatcherURLProtocol)
        NSObject.switchAllMethod()
        WXSQHttpCookieManager.putCookieIntoWeb()
        WXNetworkStatusManager.startMonitor()
//        NSObject.redirectLogToDocuments()
        
        // 主UI
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.customBackgroundColor()
        
        self.configRootViewController()
        
        return true
    }
    
    func configRootViewController()  {
        mainController = SidebarMenuViewController()
        let browserVC = ToolBarWebViewController()
        browserVC.entryUrl = AppConfiguration.Urls.guideUrl
        browserVC.sidebarDelegate = mainController
        let scanVC = ScanQRViewController()
        scanVC.delegate = mainController
        let settingVC = SettingViewController()
        let toolVC = ComposeToolViewController()
        let hostVC = HostViewController()
        let recordVC = RecordViewController()
        let consolelogVC = ConsoleLogViewController()
        consolelogVC.sTitle = "log信息"
        consolelogVC.bNeedRightBtn = true
        recordVC.sidebarDelegate = mainController

        mainController?.menuItemViewControllers = [browserVC,scanVC,toolVC,hostVC,consolelogVC,recordVC,settingVC];
        let ar = NSMutableArray()
        var browserAr = NSMutableArray()
        browserAr.addObject(SideBarModel(name: "浏览器", vc: browserVC))
        browserAr.addObject(SideBarModel(name: "扫一扫", vc: scanVC))
        ar.addObject(browserAr)
        
        browserAr = NSMutableArray()
        browserAr.addObject(SideBarModel(name: "环境切换", vc: settingVC))
        ar.addObject(browserAr)
        
        browserAr = NSMutableArray()
        browserAr.addObject(SideBarModel(name: "网络工具", vc: toolVC))
        browserAr.addObject(SideBarModel(name: "host替换", vc: hostVC))
        browserAr.addObject(SideBarModel(name: "查看console.log", vc: consolelogVC))
        browserAr.addObject(SideBarModel(name: "在浏览器打开", vc: nil))
        ar.addObject(browserAr)
        
        browserAr = NSMutableArray()
        browserAr.addObject(SideBarModel(name: "记录", vc: recordVC))
        ar.addObject(browserAr)
        
        browserAr = NSMutableArray()
        browserAr.addObject(SideBarModel(name: "网址导航", vc: nil))
        browserAr.addObject(SideBarModel(name: "帮助", vc: nil))
        ar.addObject(browserAr)
        
        mainController?.menuItemNames = ar as [AnyObject]
        mainController?.sideBarButtonImageName = "分类黑色";
        
        browserVC.hiddenCustomNavigationBar = true
        
        if let vc = mainController
        {
            self.viewController = PanNavigationController(rootViewController: vc)
            self.window?.rootViewController = self.viewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    

    class func sharedApp() -> AppDelegate?{
        let app:AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
        return app
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func handleCustomProtocolOpenURL(url: NSURL) -> Bool {
        if let vc = mainController?.containerController{
            CusSchemeHelper.openCusPageWith(vc, url: url)
        }
        return true
    }
    
    func handleOpenURL(url: NSURL, sourceApplication: String?) -> Bool {
        if handleCustomProtocolOpenURL(url) {
            //再处理自定义协议
            return true
        }
        return false
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return handleOpenURL(url, sourceApplication: nil)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return handleOpenURL(url, sourceApplication: sourceApplication)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        HttpCaptureManager.shareInstance().saveHAR()
        HttpCaptureManager.shareInstance().removeExpireHar(HttpCaptureManager.shareInstance().cachePath)
        HttpCaptureManager.shareInstance().removeExpireHar(HttpCaptureManager.shareInstance().zipPath)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


