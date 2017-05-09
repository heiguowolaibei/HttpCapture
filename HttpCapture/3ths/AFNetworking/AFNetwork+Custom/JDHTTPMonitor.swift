//
//  JDHTTPMonitor.swift
//  weixindress
//
//  Created by 杜永超 on 16/1/19.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

import UIKit

class JDHTTPMonitor: NSObject {
    
    let rootUrl = "http://wq.jd.com/webmonitor/collect/appurl.json"
    private var timer:NSTimer?
    static let sharedInstance = JDHTTPMonitor()
    var start:Bool = false
    
    var lock = NSLock()
    var dictArr = [String]()
    var sessionTaskDict = [Int:AnyObject]()
    
    
    class func startHTTPMonitor() {
        let monitor = JDHTTPMonitor.sharedInstance
        monitor.start = true
    }
    
    private override init() {
        super.init()
        //5分钟上报一次
        timer = NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: Selector("report"), userInfo: nil, repeats: true)
    }
    
    class func reportNetworkSpeed(operation operation:AFURLConnectionOperation?,orTask task:NSURLSessionTask? = nil) {
        
        guard JDHTTPMonitor.sharedInstance.start else {return}
        
        //content
        var content = ""
        
        let type = "2"
        var network = "5"

        let status = WXNetworkStatusManager.currentNetworkType()
        switch  status {
        case "WIFI":
            network = "1"
        case "2G":
            network = "4"
        case "3G":
            network = "3"
        case "4G":
            network = "2"
        default:
            network = "5"
        }
        
        if let soperation = operation
        {
            if let orgURL = soperation.request.URL?.absoluteString.componentsSeparatedByString("?").first
            {
                let dnsTime = "0"
                let connetTime = soperation.connectTime - soperation.startTime
                let responseTime = soperation.endTime - soperation.connectTime
                let totalTime = soperation.endTime - soperation.startTime
                let loadTime = "0"
                var httpCode = 0
                if let Resp = soperation.response as? NSHTTPURLResponse{
                    httpCode = Resp.statusCode
                }
                var bizResult = "0"
                if let resData = soperation.responseData,
                    let res = NSJSONSerialization.WQJSONObjectWithData(resData, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
                    if let errCode = res["errCode"] as? String {
                        bizResult = errCode
                    }else if let errCode = res["retCode"] as? String {
                        bizResult = errCode
                    }
                }
                
                content = "\(type)|\(network)|\(orgURL)|\(dnsTime)|\(connetTime)|\(responseTime)|\(totalTime)|\(loadTime)|\(httpCode)|\(bizResult)"
            } else {
                return
            }
        }else if let task = task {
            // 上报请求用session，不需要上报，要不就死循环了
            guard task.noNeedReport == false else { return }

            
            if let orgURL = task.originalRequest?.URL?.absoluteString.componentsSeparatedByString("?").first{
                let dnsTime = "0"
                var connetTime = 0.0
                var responseTime = 0.0
                var totalTime = 0.0
                if task.connectTime_2 != 0 {
                    connetTime = task.connectTime_2 - task.startTime_2
                    responseTime = task.endTime_2 - task.connectTime_2
                }
                totalTime = task.endTime_2 - task.startTime_2

                let loadTime = "0"
                var httpCode = 0
                if let Resp = task.response as? NSHTTPURLResponse{
                    httpCode = Resp.statusCode
                }
                let bizResult = "0"
                
                content = "\(type)|\(network)|\(orgURL)|\(dnsTime)|\(connetTime)|\(responseTime)|\(totalTime)|\(loadTime)|\(httpCode)|\(bizResult)"
            } else {
                return
            }
        }else{
            return
        }
        JDHTTPMonitor.sharedInstance.lock.lock()
        JDHTTPMonitor.sharedInstance.dictArr.append(content)
        JDHTTPMonitor.sharedInstance.lock.unlock()
        if JDHTTPMonitor.sharedInstance.dictArr.count >= 5 {
            JDHTTPMonitor.sharedInstance.report()
        }
    }
    
    func report() {
        
    }
}

//@available(iOS 8, *)
extension NSURLSessionTask {

    private struct AssociatedKeys {
        static var startTime:NSNumber?
        static var connectTime:NSNumber?
        static var endTime:NSNumber?
        static var responseObj:AnyObject?
        static var noNeedReport:NSNumber?
        static var extensionMessage:NSString?
    }
    
    public var startTime_2:NSTimeInterval {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.startTime) as? NSNumber {
                return value.doubleValue
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.startTime, NSNumber(double: newValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var connectTime_2:NSTimeInterval{
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.connectTime) as? NSNumber {
                return value.doubleValue
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.connectTime, NSNumber(double: newValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var endTime_2:NSTimeInterval{
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.endTime) as? NSNumber {
                return value.doubleValue
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.endTime, NSNumber(double: newValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var responseObj_2:AnyObject? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.responseObj)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.responseObj, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var noNeedReport:Bool{
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.noNeedReport) as? NSNumber {
                return value.boolValue
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.noNeedReport, NSNumber(bool: newValue) , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var extensionMessage:String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.extensionMessage) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.extensionMessage, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func  isFinished() -> Bool {
        return self.state == NSURLSessionTaskState.Completed
    }
}
