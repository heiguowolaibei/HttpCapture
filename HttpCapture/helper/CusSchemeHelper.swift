//
//  CusSchemeHelper.swift
//  weixindress
//
//  Created by mac  on 15/5/28.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation

public struct ShareManagerMetaData {
    static let QQConnect_APP_ID: String = "1104340788"
    static let QQApi_APP_ID: String = "QQ0003640E"
    //    static let WeChat_APP_ID: String = "wx8b5ba6284191d1c9"
    static let WeChat_APP_ID: String = "wxe3384655cdb13ab6"
    //    static let WeChat_APP_ID: String = "wx7bbc07fcb902d31f"
    static let WX_PAY_PARTNER_ID = "1234190302"
    static let Custom_Scheme = "com.jd.jzyc"
    //FIXME: 修改Pay商户号
    static let ApplePay_Mechant_ID = "merchant.com.am.u1"
}

public struct CustomSkipType{
    static let webviewType:String = "webview"
    static let loginviewType:String = "loginViewPage"
    static let mainType:String = "mainPage"
    static let homePageType:String = "homepage"
}
class CusSchemeHelper:NSObject{
    
    class func pushSearchLocalViewController(absoluteString:String,navi:UINavigationController){
        if let data = absoluteString.onGetSubString("param=", sEnd: "", isInt: false).dataUsingEncoding(NSUTF8StringEncoding)
        {
            let obj = NSJSONSerialization.WQJSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if let dic = obj as? Dictionary<String,AnyObject> , let str = dic["url"] as? String
            {
                var key = absoluteString.onGetSubString( "key=", sEnd: "#", isInt: false)
                
                if key.length == 0
                {
                    key = absoluteString.onGetSubString("key=", sEnd: "\"", isInt: false)
                }
                
                if key.length == 0
                {
                    key = absoluteString.onGetSubString("key=", sEnd: "&", isInt: false)
                }
                
                let _key = (key as NSString).stringByReplacingPercentEscapesAndPlusUsingEncoding(NSUTF8StringEncoding)
                if _key.length > 0
                {
                    
                }
            }
        }
    }

    class func openCusPageWith(rootNaviVC:UINavigationController,url:NSURL!){
        if let absoluteString = url.absoluteString.stringByRemovingPercentEncoding {
            let cusRange = (absoluteString as NSString).rangeOfString(AppConfiguration.Defaults.scheme)
            if cusRange.location != NSNotFound {
                //如果打开webview
                let webskipPageRange = (absoluteString as NSString).rangeOfString(CustomSkipType.webviewType)
                if webskipPageRange.location != NSNotFound{
                    onOpenWebView(rootNaviVC, absoluteString: absoluteString)
                }
            }
        }
    }
    
    class func onDismissPresent(rootNaviVC:UINavigationController?) {
        if rootNaviVC?.presentedViewController != nil{
            rootNaviVC?.dismissViewControllerAnimated(false, completion: { () -> Void in
                
            })
        }
    }
    
    dynamic class func preprocessURL(url:String) -> String
    {
        return url
//        return  url.getSpecialCharacterEncodeString()
    }
    
    class func onOpenWebView(rootNaviVC:UINavigationController?,absoluteString:String) -> (issuccess:Bool,tab:Int,subTab:Int)
    {
        if let navi = rootNaviVC where (absoluteString as NSString).rangeOfString("search/style13/search.shtml").location != NSNotFound
        {
            self.pushSearchLocalViewController(absoluteString, navi: navi)
            return (true,0,0)
        }
        
        let beginIndex = (absoluteString as NSString).rangeOfString("param=").location + 6
        if absoluteString.length > 6 {
            let paramString = (absoluteString as NSString).substringFromIndex(beginIndex)
            if let data = (paramString as NSString).dataUsingEncoding(NSUTF8StringEncoding),let dic = JsonParser.jsonpParse(data)
            {
                var urlString = ""
                var selectTab = -1
                var subTabInt = -1

                if let json = dic["url"] as? String {
                    urlString = json
                }
                
                if let tab = dic["tab"] as? String, let intTab = Int(tab) {
                    selectTab = intTab
                }
                
                if let tab = dic["subTab"] as? String, let intTab = Int(tab) {
                    subTabInt = intTab
                }

                var skipUrlString = urlString
                let enterWebViewVC = CommonWebViewController()
                skipUrlString = CusSchemeHelper .preprocessURL(skipUrlString)
                enterWebViewVC.entryUrl = skipUrlString as String
                
                enterWebViewVC.hidesBottomBarWhenPushed = true
                
                if skipUrlString.length > 0{
                    self.onDismissPresent(rootNaviVC)
//                    rootNaviVC?.pushViewController(enterWebViewVC, animated: true)
                    
                    if let mainvc = AppDelegate.sharedApp()?.mainController, let indexpath = mainvc.getSearchWebControllerIndexPath(),let last = mainvc.containerController.viewControllers.last,let indexpath2 = mainvc.getMenuItemIndexPath(last)
                    {
                        mainvc.setToolbarURL(skipUrlString)
                        mainvc.selectIndexPath(indexpath2, animationFinishBlock: { (finish) in
                            mainvc.selectIndexPath(indexpath, animationFinishBlock: { (finish) in
                                
                            })
                        })
                    }
                }
                return ( true,selectTab,subTabInt)
            }
        }
        return (false,0,0)
    }
    
}











