//
//  ToolViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/24.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony

enum DiagnoseStatus : Int {
    case notDefined = -1,
    pingType = 0,
    dnsType = 1,
    traceType = 2
}

@objc class ComposeToolViewController: TextViewController,PingDelegate,UITextFieldDelegate,LDNetTraceRouteDelegate,UIDocumentInteractionControllerDelegate
{
    var textfield = UITextField()
    var host = "wq.jd.com"
    let ping = PingHelper.shareInstance()
    var bFirst = true
    var rightV:UIButton?
    var deviceinfo = ""
    var currentType = DiagnoseStatus.notDefined
        {
        didSet{
            
        }
    }
    var isBegan = false
        {
        didSet{
            haveBeganChanged()
        }
    }
    var documentInteractionController:UIDocumentInteractionController?;
    
    var _traceRouter:LDNetTraceRoute?
    
    override var text: String
        {
        didSet{
            if text.length/1024/1024 > 1 {
                MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("文件内容过大", delayTime: 3)
            }
            else{
                let attritext = NSAttributedString(string:text);
                textView.attributedText = attritext
            }
        }
    }
    
    override func viewDidLoad() {
        self.sTitle = "网络工具"
        super.viewDidLoad()
        
        textfield.layer.borderColor = UIColor.fromRGB(0x222222).CGColor
        textfield.layer.borderWidth = 1/WXDevice.scale
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.delegate = self;
        textfield.layer.cornerRadius = 3;
        let cLeftV = UIView(frame: CGRectMake(0, 0, 10, 10))
        cLeftV.backgroundColor = UIColor.clearColor()
        textfield.leftView = cLeftV
        textfield.leftViewMode = .Always
        textfield.layer.masksToBounds = true
        textfield.text = host
        
        rightV = UIButton(frame: CGRectMake(self.textfield.width - 60,0,60,44))
        rightV?.setTitle("开始", forState: UIControlState.Normal)
        rightV?.layer.cornerRadius = 3;
        rightV?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        rightV?.backgroundColor = UIColor.colorWithRGB(red: 0, green: 122, blue: 255)
        rightV?.addTarget(self, action: "beginEnd", forControlEvents: UIControlEvents.TouchUpInside)
        textfield.rightView = rightV
        textfield.rightViewMode = .Always
        
        self.view.addSubview(textfield)
        
        var images = [(UIImage,UIImage,String)]()
        if let img = CommonImageCache.getImage(named:"清空") {
            images.append((img, img, "rightButtonClick:"))
        }
        if let img = CommonImageCache.getImage(named:"feed_share_icon") {
            images.append((img, img, "share"))
        }
        self.setRightButtons(images)
        
        self.text = self.getDeviceInfo()
        
        ping.pingDelegate = self;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if bFirst {
            bFirst = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func toolTypeChanged() {
        
    }
    
    override func rightButtonClick(item: UIButton) {
        self.clearText()
    }
    
    func share(){
        MBProgressHUDHelper.sharedMBProgressHUDHelper.showAnimated(true, text: "读取文件内容")
        dispatch_async(dispatch_get_global_queue(0, 0), {
            var content = ""
            do {
                try content = self.textView.attributedText.string
            } catch let err as NSError {
                DPrintln("err = \(err)")
            }
            var key = NSString(format: "%.1f", NSDate().timeIntervalSince1970) as String
            let path = FileHelper.CacheRootPath.stringByAppendingString("/monitor/diagnoseLog_\(key).txt");
            do {
                try content.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            } catch let err as NSError {
                
            }
            UIPasteboard.generalPasteboard().string = content
            
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUDHelper.sharedMBProgressHUDHelper.hidden(nil, animation: false)
                
                let url = NSURL(fileURLWithPath: path)
                self.documentInteractionController = UIDocumentInteractionController(URL: url)
                self.documentInteractionController?.delegate = self;
                self.documentInteractionController?.presentOptionsMenuFromRect(CGRectMake(self.view.width/2 - 100/2, self.view.height/2 - 100/2, 100, 100), inView: self.view, animated: true)
            })
        })
    }
    
    func clearText() {
        self.text = self.getDeviceInfo()
    }
    
    func haveBeganChanged() {
        let title = self.isBegan == true ? "停止":"开始"
        rightV?.setTitle(title, forState: UIControlState.Normal)
    }
    
    func beginEnd() {
        self.isBegan = !self.isBegan
        
        if self.textfield.isFirstResponder()
        {
            textfield.resignFirstResponder()
            self.text = self.getDeviceInfo()
            if let ss = textfield.text
            {
                host = ss
            }
            self.stopCurrentOperation()
            self.textfield.resignFirstResponder()
        }
        
        if self.isBegan {
            ping.toPing(host)
        }
        else{
            self.stopCurrentOperation()
        }
    }
    
    func stopCurrentOperation(){
        ping.stopping()
        _traceRouter?.stopTrace()
    }
    
    func getDeviceInfo() -> String {
        if deviceinfo.length == 0 {
            deviceinfo += "设备信息：\r\n"
            deviceinfo += "应用名：\(WXDevice.appName)\r\n"
            deviceinfo += "应用版本：\(WXDevice.shortVersion)\r\n"
            deviceinfo += "应用编译版本：\(WXDevice.bundleVersion)\r\n"
            deviceinfo += "机器类型：\(UIDevice.currentDevice().systemName)\r\n"
            deviceinfo += "设备名称：\(UIDevice.currentDevice().platformString())\r\n"
            deviceinfo += "系统版本：\(UIDevice.currentDevice().systemVersion)\r\n"
            deviceinfo += "UUID：\(WXSQDeviceInfoUtil.uuidForDevice())\r\n"
            deviceinfo += "广告标识符IDFA：\(WXDevice.idfa)\r\n"
            
            if let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
            {
                if let name = carrier.carrierName
                {
                    deviceinfo += "运营商：\(name)\r\n"
                }
                if let code = carrier.isoCountryCode
                {
                    deviceinfo += "ISOCountryCode：\(code)\r\n"
                }
                if let code = carrier.mobileCountryCode
                {
                    deviceinfo += "mobileCountryCode：\(code)\r\n"
                }
                if let code = carrier.mobileNetworkCode
                {
                    deviceinfo += "mobileNetworkCode：\(code)\r\n"
                }
            }
            
            deviceinfo += "当前网络类型：\(WXNetworkStatusManager.currentNetworkType())\r\n"
            deviceinfo += "本机ip：\(NSString.getIPAddress())\r\n"
            deviceinfo += "本机网关：\(NSString.getGatewayIPV4Address())\r\n"
            deviceinfo += "本机DNS：\(NSString.getDNSs())\r\n"
            
            deviceinfo += "\r\n"
        }
        
        return deviceinfo
    }
    
    func traceroute() {
        if self.isBegan {
            if let traceRouter = LDNetTraceRoute(maxTTL: TRACEROUTE_MAX_TTL, timeout: TRACEROUTE_TIMEOUT, maxAttempts: TRACEROUTE_ATTEMPTS, port: TRACEROUTE_PORT)
            {
                _traceRouter = traceRouter
                _traceRouter?.delegate = self;
                NSThread.detachNewThreadSelector("doTraceRoute:", toTarget: traceRouter, withObject: host)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textfield.frame = CGRectMake(10, 64 + 10, self.view.width - 2*10, 44)
        textView.frame = CGRectMake(10, textfield.bottom + 10, self.view.width - 2*10, self.view.height - 10 - (textfield.bottom + 10))
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        beginEnd()
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    func pingLogCallBack(log: String!) {
        var pingText = self.getDeviceInfo()
        if let text = self.textView.attributedText {
            pingText = text.string;
        }
        
        if currentType == .notDefined {
            pingText += "ping连通测试开始\r\n\r\n" + log + "\r\n\r\n";
        }
        else{
            pingText += log + "\r\n\r\n";
        }
        
        currentType = .pingType
        
        self.text = pingText
        self.textView.scrollRangeToVisible(NSMakeRange(text.length - 2, 2))
    }
    
    func pingDidEnd(){
        self.pingLogCallBack("ping连通测试结束")
        beginParseHost()
    }
    
    func beginParseHost()
    {
        if self.isBegan {
            HostResoluteHelper().parseHost(self.textfield.text, block: { (type, obj, time) in
                var s = ""
                if self.currentType == .pingType
                {
                    s = "域名解析开始\r\n" + "ip地址:\(obj);\r\n耗时:\(time)";
                }
                else{
                    s = "ip地址:\(obj);\r\n耗时:\(time)"
                }
                self.text += "\r\n" + s + "\r\n域名解析结束";
                self.currentType = .dnsType
                
                self.traceroute()
            })
        }
    }
    
    func appendRouteLog(routeLog: String!) {
        dispatch_async(dispatch_get_main_queue()) {
            if let log = routeLog {
                var routeText = self.getDeviceInfo()
                if let text = self.textView.attributedText
                {
                    routeText = text.string + "\r\n";
                }
                
                if self.currentType == .dnsType
                {
                    routeText += "\r\n\r\ntraceroute开始\r\n"
                }
                self.currentType = .traceType
                
                routeText += log + "\r\n" ;
                
                self.text = routeText
                self.textView.scrollRangeToVisible(NSMakeRange(self.text.length - 2, 2))
            }
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self;
    }
    
    func traceRouteDidEnd() {
        self.appendRouteLog("traceroute结束\r\n")
        self.isBegan = false
        currentType = .notDefined
    }
    
    override func useDefaultBackButton() -> Bool{
        return false;
    }
    
    deinit
    {
        self.textView.resignFirstResponder()
        self.textfield.resignFirstResponder()
    }
    
}
