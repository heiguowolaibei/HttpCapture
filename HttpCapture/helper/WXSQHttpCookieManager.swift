//
//  WXSQHttpCookieManager.swift
//  weixindress
//
//  Created by louyunping on 15/4/3.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

/**
*   cookie 管理类
*   http 请求时，加入cookie
*/

struct LoginUserKey {
    static let USERINFO_USER        = "user_loginuserinfo"
}

struct CookieManagerExt {
    static var allCookieKey:NSMutableArray = NSMutableArray()
    static let cookieKey:String = "WEB_COOKIE_KEY"
    static let tempCookieKey:String = "WEB_TEMP_COOKIE_KEY"
    
    static let COOKIE_TIMEOUT:String = String(60 * 60 * 24 * 30)
}

class WXSQHttpCookieManager: NSObject {
    
    class var cookieWQSHost:NSURL {
        return NSURL(string: "http://wqs.jd.com")!
    }
    
    class var cookieWQHost:String {
//        return NSURL(string: "http://.jd.com")!
        return ".jd.com"
    }
    
    class var cookieWQPath:String {
        return "/"
    }

    
    class var cookieKeys:NSMutableArray{
        return NSMutableArray()
    }
    
    override init() {
        super.init()
    }
    
    // 当程序启动访问webview时，添加cookie
    class func putCookieIntoWeb(){
        self.appendUserAgentToWeb()
    }
    
    class func addCookieWithNameAndValue(name:String,value:String,host:String,path:String) -> NSHTTPCookie {
        let maxAge:String = CookieManagerExt.COOKIE_TIMEOUT //"3600000"
        
        let property:Dictionary<String,String> = [NSHTTPCookieDomain:host,NSHTTPCookiePath:path,NSHTTPCookieName:name,NSHTTPCookieValue:value,NSHTTPCookieMaximumAge:String(maxAge)] as Dictionary<String,String>
        let cookie:NSHTTPCookie = NSHTTPCookie(properties: property)!
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
        return cookie
    }
    
    static func onGetCookieValueByCookieName(name:String) -> String{
        var cookieValue:String = ""
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies{
            for cookie in cookies {
                if cookie.name == name {
                    cookieValue = cookie.value
                    break
                }
            }
        }
        
        return cookieValue
    }
    
 
    
    class func addClientidCookie() {
        let deviceId:String = WXDevice.deviceId as String
        
        let host:String = cookieWQHost //.host!
        
        let clientidProperty:Dictionary<String,String> = [NSHTTPCookieDomain:String(host),NSHTTPCookiePath:cookieWQPath,NSHTTPCookieName:String("clientid"),NSHTTPCookieValue:deviceId] as Dictionary<String,String>
        if let clientidCookie:NSHTTPCookie = NSHTTPCookie(properties: clientidProperty)
        {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(clientidCookie)
        }
    }
    
    class func onGetJDCookieStrings() -> String{
        var sBack = ""
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies{
            for (value,cookie) in cookies.enumerate(){
                if value == cookies.count - 1{
                    sBack += cookie.name + "=" + cookie.value
                }
                else{
                    sBack += cookie.name + "=" + cookie.value + ";"
                }
            }
        }
        
        return sBack
    }
    
    class func deleteCookie() {
        
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!
        let cookieKeys:NSMutableArray? = NSUserDefaults.getObjectFromUserDefaults(CookieManagerExt.cookieKey) as? NSMutableArray
        if cookieKeys != nil {
            for cookie in cookies {
                let cookieName = cookie.name
                if  (cookieKeys!.containsObject(cookieName) == true && cookie.domain == cookieWQHost)
                {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
                }
                //注销后清空购物车和地址cookie
                if cookieName == "cartNum" || cookieName == "jdAddrId"{
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
                }
            }
        }
    }
    
    class func generateCookie(var cookies:Dictionary<String,AnyObject>) -> Array<AnyObject>{
        var allCookie:Array<AnyObject> = []
        let allCookieKeys:NSMutableArray = NSMutableArray()
        
        var devicetoken:String = ""
        if let devicetokenValue: AnyObject = NSUserDefaults.getObjectFromUserDefaults(AppConfiguration.Defaults.apnsToken) {
            devicetoken = "\(devicetokenValue)"
        }
        cookies["xgToken"] =  devicetoken
        cookies["buy_uin"] = cookies["wg_uin"]
        for k in cookies.keys {
            var cookieValue:String = "\(cookies[k]!)"
            var key = k
            if key == "nickname" {
                let nicknameTuple = self._disposeString(cookieValue)
                key = nicknameTuple.key
                cookieValue = nicknameTuple.value
            }
            else if key == "headimgurl" {
                let nicknameTuple = self._disposeString(cookieValue)
                key = nicknameTuple.key
                cookieValue = nicknameTuple.value
            }
            else if key == "type" {
                continue
            }
            
            let cookieName:String = String(key)
            allCookieKeys.addObject(cookieName)
            
            cookieValue = cookieValue.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
//            let cookie:NSHTTPCookie  = self.addCookieWithNameAndValue(cookieName, value: cookieValue)
            
//            allCookie.append(cookie)
        }
        NSUserDefaults.setObjectToUserDefaults(allCookieKeys, key: CookieManagerExt.cookieKey)
        
        return allCookie
    }
    
    // 当退出登录后，cookie可能没有清空完。为解决该问题，先判断本地的用户信息是否存在，如果不存在，表示用户已退出，再次清空用户cookie
    class func redeleteCookieAfterLogout() {
        let userInfo:AnyObject? = NSUserDefaults.getObjectFromUserDefaults(LoginUserKey.USERINFO_USER)
        if userInfo == nil {
            self.deleteCookie()
        }
    }
    
    //由于cookie中有时会存在两个key为cid的值，为解决这个问题，先将cid清空掉再重新添加
    class func addCookieForCID() {
        
    }
    
    // 该方法会在每次webView加载的时候都调用
    class func initalizedCookie() {
        redeleteCookieAfterLogout()
    }
    
    // 字符串根据 “||” 截取
    class func _disposeString(content:String?) -> (value:String, key:String){
        if ((content != nil) && (content != "")) {
            if let tempArr:NSArray = content?.componentsSeparatedByString("||") {
                let mArray:NSMutableArray = tempArr.mutableCopy() as! NSMutableArray
                if  mArray.count >= 2 {
                    let key:String = mArray.objectAtIndex(0) as! String
                    mArray.removeObjectAtIndex(0)
                    let tContent:String = mArray.componentsJoinedByString("||")
                    return (tContent,key)
                }
            }
        }
        
        let value:String = content == nil ? "" : content!
        
        return (value, "tuple")
    }
    
    class func appendUserAgentToWeb() {
        if let oldUserAgent:String = UIWebView().stringByEvaluatingJavaScriptFromString("navigator.userAgent") {
            let newUserAgent = (oldUserAgent as NSString).getConvertUA()
            let uAgentDic:NSDictionary = ["UserAgent":newUserAgent]
            NSUserDefaults.standardUserDefaults().registerDefaults(uAgentDic as! [String : AnyObject])
        }
    }
    
    class func generateStringByCookies() -> String{
        var rs: String = ""
        
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!
        rs = cookies.reduce("", combine: { (r:String, c:NSHTTPCookie) -> String in
            let cv = c.value
            
            if cookies.first == c {
                return c.name + "=" + cv + r
            }
            else {
               return c.name + "=" + cv + ";" + r
            }
            
        })
        return rs
    }

}
