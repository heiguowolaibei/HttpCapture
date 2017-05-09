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

enum ToolType : Int {
    case pingType = 0,
    dnsType = 1,
    traceType = 2
}

@objc class ToolViewController: TextViewController,PingDelegate,UITextFieldDelegate,LDNetTraceRouteDelegate {
    var textfield = UITextField()
    var host = "wq.jd.com"
    let ping = PingHelper.shareInstance()
    var bFirst = true
    var rightV:UIButton?
    var deviceinfo = ""
    var toolType = ToolType.pingType
        {
        didSet{
            
        }
    }
    var typeText = [ToolType:NSAttributedString]()
    var typeIsBegin = [ToolType:Bool]()
        {
        didSet{
            self.typeIsBeginChanged()
        }
    }

    var _traceRouter:LDNetTraceRoute?
    
    override var text: String
    {
        didSet{
            if text.length/1024/1024 > 1 {
                MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("文件内容过大", delayTime: 3)
            }
            else{
                segment.hidden = false
                let attritext = NSAttributedString(string:text);
                textView.attributedText = attritext
                
                typeText[toolType] = attritext
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segment.removeAllSegments()
        segment.insertSegmentWithTitle("ping测试", atIndex: 1, animated: false)
        segment.insertSegmentWithTitle("域名解析", atIndex: 2, animated: false)
        segment.insertSegmentWithTitle("路由", atIndex: 3, animated: false)
        
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
        
        rightBtn.frame = CGRectMake(0, 0, 44, 44)
        rightBtn.contentHorizontalAlignment = .Right
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
        rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
        rightBtn.setTitle("清除", forState: UIControlState.Normal)
        rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem
        
        segment.hidden = false
        segment.selectedSegmentIndex = 0
        
        self.text = self.getDeviceInfo()
        
        self.resetTypeIsBegin()
        
        ping.pingDelegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if bFirst {
            segment.selectedSegmentIndex = 0
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
    
    func clearText() {
        self.text = self.getDeviceInfo()
        let attritext = NSAttributedString(string: self.text)
        typeText[ToolType.dnsType] = attritext
        typeText[ToolType.pingType] = attritext
        typeText[ToolType.traceType] = attritext
    }

    func typeIsBeginChanged() {
        let value = self.typeIsBegin[self.toolType]
        switch self.toolType {
        case .pingType:
            if value == true {
//                self.text = self.getDeviceInfo()
            }
            break
        case .traceType:
            
            break
        case .dnsType:
            
            break
        }
        
        if self.toolType != .dnsType
        {
            let title = value == true ? "停止":"开始"
            rightV?.setTitle(title, forState: UIControlState.Normal)
        }
    }
    
    func beginEnd() {
        if self.textfield.isFirstResponder()
        {
            textfield.resignFirstResponder()
            self.text = self.getDeviceInfo()
            if let ss = textfield.text
            {
                host = ss
            }
            typeIsBegin[self.toolType] = false
            self.stopCurrentOperation()
            self.textfield.resignFirstResponder()
        }
        
        if let isBegin = typeIsBegin[self.toolType] {
            switch self.toolType {
            case .pingType:
                if !isBegin  {
                    ping.toPing(host)
                }
                else {
                    ping.stopping()
                }
                break;
            case .dnsType:
                if !isBegin  {
                    HostResoluteHelper().parseHost(self.textfield.text, block: { (type, obj, time) in
                        let s = "ip地址:\(obj);\r\n耗时:\(time)"
                        self.text += "\r\n\r\n" + s;
                        self.typeIsBegin[ToolType.dnsType] = false
                    })
                }
                else {
                    
                }
                break;
            case .traceType:
                if !isBegin  {
                    self.traceroute()
                }
                else {
                    _traceRouter?.stopTrace()
                }
                break;
            }
            
            typeIsBegin[self.toolType] = !isBegin
        }
    }
    
    func stopCurrentOperation(){
        switch self.toolType {
        case .pingType:
            ping.stopping()
            break;
        case .dnsType:
            break;
        case .traceType:
            _traceRouter?.stopTrace()
            break;
        }
        
        self.resetTypeIsBegin()
    }
    
    func resetTypeIsBegin() {
        typeIsBegin =
            [ToolType.pingType:false,
             ToolType.dnsType:false,
             ToolType.traceType:false]
    }
    
    func getDeviceInfo() -> String {
        if deviceinfo.length == 0 {
            deviceinfo += "应用名：\(WXDevice.appName)\r\n"
            deviceinfo += "应用版本：\(WXDevice.shortVersion)\r\n"
            deviceinfo += "应用编译版本：\(WXDevice.bundleVersion)\r\n"
            deviceinfo += "机器类型：\(UIDevice.currentDevice().systemName)\r\n"
            deviceinfo += "设备名称：\(UIDevice.currentDevice().platformString())\r\n"
            deviceinfo += "系统版本：\(UIDevice.currentDevice().systemVersion)\r\n"
            deviceinfo += "UUID：\(WXSQDeviceInfoUtil.uuidForDevice())\r\n"
            
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
        if let traceRouter = LDNetTraceRoute(maxTTL: TRACEROUTE_MAX_TTL, timeout: TRACEROUTE_TIMEOUT, maxAttempts: TRACEROUTE_ATTEMPTS, port: TRACEROUTE_PORT)
        {
            _traceRouter = traceRouter
            _traceRouter?.delegate = self;
            NSThread.detachNewThreadSelector("doTraceRoute:", toTarget: traceRouter, withObject: host)
        }
    }
    
    override func segchange() {
        self.stopCurrentOperation()
        if segment.selectedSegmentIndex == 0
        {
            if let type = ToolType(rawValue: 0)
            {
                self.toolType = type
                if let stext = typeText[type]
                {
                    self.text = stext.string
                }
                else{
                    self.text = self.getDeviceInfo()
                }
            }
        }
        if segment.selectedSegmentIndex == 1
        {
            if let type = ToolType(rawValue: 1)
            {
                self.toolType = type
                if let stext = typeText[type]
                {
                    self.text = stext.string
                }
                else{
                    self.text = self.getDeviceInfo()
                }
            }
        }
        if segment.selectedSegmentIndex == 2
        {
            if let type = ToolType(rawValue: 2)
            {
                self.toolType = type
                if let stext = typeText[type]
                {
                    self.text = stext.string
                }
                else{
                    self.text = self.getDeviceInfo()
                }
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        beginEnd()
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    func pingLogCallBack(log: String!) {
        var pingText = self.getDeviceInfo()
        if let text = self.typeText[ToolType.pingType] {
            pingText = text.string;
        }
        
        pingText += log + "\r\n\r\n" ;
        self.typeText[ToolType.pingType] = NSAttributedString(string: pingText)
        
        if self.toolType == .pingType {
            self.text = pingText
            self.textView.scrollRangeToVisible(NSMakeRange(text.length - 2, 2))
        }
    }
    
    func pingDidEnd(){
        self.pingLogCallBack("ping连通测试结束")
        self.typeIsBegin[ToolType.pingType] = false
    }

    func appendRouteLog(routeLog: String!) {
        dispatch_async(dispatch_get_main_queue()) {
            if let log = routeLog {
                var routeText = self.getDeviceInfo()
                if let text = self.typeText[ToolType.traceType]
                {
                    routeText = text.string;
                }
                
                routeText += log + "\r\n\r\n" ;
                let attributeText = NSAttributedString(string: routeText)
                self.typeText[ToolType.traceType] = attributeText
                
                if self.toolType == .traceType {
                    self.text = routeText
                    self.textView.scrollRangeToVisible(NSMakeRange(self.text.length - 2, 2))
                }
            }
        }
    }
    
    func traceRouteDidEnd() {
        self.appendRouteLog("网络诊断结束")
        self.typeIsBegin[ToolType.traceType] = false
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
