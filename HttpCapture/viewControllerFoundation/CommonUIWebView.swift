
//
//  CommonUIWebView.swift
//  weixindress
//
//  Created by timothywei on 15/4/5.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore

// URL打开位置
enum LinkTarget:Int {
    // 未设置
    case None = 0
    
    // 当前页面打开
    case Current = 1
    
    // 弹出新的页面
    case Blank = 2
}


@objc protocol CommonUIWebViewDelegate : NSObjectProtocol
{
    optional func webView(webView: CommonUIWebView?, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType)
    optional func webViewDidStartLoad(webView: CommonUIWebView?)
    optional func webViewDidFinishLoad(webView: CommonUIWebView?)
    optional func webView(webView: CommonUIWebView?, didFailLoadWithError error: NSError)
    optional func webView(webView: CommonUIWebView?, didChangeURL:String)
    optional func scrollViewDidScroll(scrollView: UIScrollView)
}

class CommonUIWebView: UIWebView, UIWebViewDelegate,NJKWebViewProgressDelegate {
    var refreshView:MJRefreshJZBaseHeader?
    
    private var isLoadErrPage:Bool = false
    
    var currentUrl:String = ""
    var lastWebViewUrl:String = ""
    var newCurrentUrl:String = ""
    
    private var lastRefreshTimestamp:Double = 0.0
    private var enableHeadRefresh:Bool = true
    private var enableBottomRefresh:Bool = true
    private var lastEvalWindowOnBottom:Double  = 0
    private var delegates:[CommonUIWebViewDelegate] = [CommonUIWebViewDelegate]()
    private var hasStartLoad:Bool = false
    private var hasUseContentOffsetKOC:Bool = false
    private var urlLoadHistoryDict: Dictionary<String,Bool?> = Dictionary<String,Bool?> ()
    private var lastRequestUrlString:String = ""
    
    var jsContext:JSContext?
    var progressProxy:CusWebViewProgress?
    var progressView:NJKWebViewProgressView?
    weak var fatherViewControler:UIViewController?
    
    var onShouldStartLoadWithRequest:((webView: CommonUIWebView?, request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Void)?
    var onWebViewDidFinishLoad:((webView:CommonUIWebView?) -> Void )?
    var onWebViewDidStartLoad:((webView:CommonUIWebView?) -> Void )?
    var onDidFailLoadWithError:((webView: CommonUIWebView?, error: NSError) -> Void )?
    var scrollViewDidScroll:((scrollView: UIScrollView) -> Void)?
    
    var onStartScroll:( (scroll:UIScrollView)->Void )?
    
    var defaultLinkTarget:LinkTarget = LinkTarget.None
    
    var logoutSucces:((Bool)->Void)? // 退出登功成功后，刷新个人信息
    var isLogoutSuccess:Bool = false
    var shouldStartUrl = ""
    
    deinit
    {
        DPrintln("==================== CommonUIWebView ====================")
        self.clear()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setScrollDecelerate(0.998)
        self.scrollView.alwaysBounceVertical = false

        self.initDelegate()
        self.initNotify()
        self.initJSCore()
        self.backgroundColor = UIColor.whiteColor()
        self.mediaPlaybackRequiresUserAction = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setScrollDecelerate(0.998)
        self.initDelegate()
        self.initNotify()
        self.backgroundColor = UIColor.whiteColor()
        self.initJSCore()
        self.initProgress()
        self.mediaPlaybackRequiresUserAction = false
    }
    
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        self.progressView?.setProgress(progress, animated: true)
    }
    
    func viewWillAppear(animated: Bool)
    {
        self.setShouldHideAlert(false)
        if self.progressView != nil
        {
            self.viewController()?.navigationBar.addSubview(progressView!)
        }
        initProgress()
    }
    
    func viewWillDisappear(animated: Bool)
    {
        self.setShouldHideAlert(true)
        if self.progressView != nil
        {
            self.progressView?.removeFromSuperview()
        }
    }
    
    func initProgress()
    {
        if self.progressProxy == nil
        {
            let progressProxy = CusWebViewProgress()
            self.progressProxy = progressProxy
            self.delegate = progressProxy
            progressProxy.webViewProxyDelegate = self
            progressProxy.progressDelegate = self
        }
        if let navigationBarBounds = self.fatherViewControler?.navigationBar.bounds where self.progressView == nil
        {
            let progressBarHeight:CGFloat = 2.0
            let barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight)
            let progressView   = NJKWebViewProgressView(frame: barFrame)
            self.progressView = progressView
            self.fatherViewControler?.navigationBar.addSubview(progressView)
            progressView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        }
    }
    
    func initJSCore()
    {
        self.switchLog()
        self.jsContext = self.switchAlert()
        self.loadHTMLString("<html></html>", baseURL: nil)
    }
    
    
    
    func clear() {
        
        self.stopLoading()
        self.removeAllSubviews()
        self.onShouldStartLoadWithRequest = nil
        self.onWebViewDidFinishLoad = nil
        self.onWebViewDidStartLoad = nil
        self.onDidFailLoadWithError = nil
        self.logoutSucces = nil
        self.delegates.removeAll(keepCapacity: false)
        self.delegate = nil
        
        self.scrollView.removeHeader()
        self.scrollView.delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self, name: WXNetworkStatusManager.NetworkStatusChangeKey, object: nil)
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "WebKitCacheModelPreferenceKey")
    }
    
    // MARK: 初始化下拉刷新
    private func initRefreshHeaderView() {
        let scrollView:UIScrollView = self.scrollView
        
        refreshView = scrollView.addJDHeaderViewWithRefreshingBlock { [weak self]() -> Void in
            
            self?.refreshCurrentWebview()
        }
        
        refreshView?.updatedTimeHidden = true
        refreshView?.setTitle("有一种刷新叫放手", forState: MJRefreshHeaderStatePulling)
        refreshView?.setTitle("正在刷新...", forState: MJRefreshHeaderStateRefreshing)
        
        refreshView?.font = UIFont.systemFontOfSize(10)
        refreshView?.textColor = UIColor.fromRGBA(0x999999ff)
    }
    
    private func refreshCurrentWebview() {
        self.stopLoading()
        self.loadUrl(self.currentUrl)
    }
    
    private func initNotify(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNetworkStatusChange:", name: WXNetworkStatusManager.NetworkStatusChangeKey, object: nil)
    }
    
    func onNetworkStatusChange(notity:NSNotification){
        if let isload = self.urlLoadHistoryDict[self.currentUrl]    {
            if isload == true {
                return
            }
        }
        
        self.loadUrl(self.currentUrl)
    }
    
    private func initDelegate()
    {
        weak var weakSelf = self
        self.delegate = weakSelf
        
        self.updateStatusControl()
        
        if logoutSucces == nil {
            logoutSucces = {(isLogout)->Void in
                if isLogout {
                    weakSelf!.isLogoutSuccess = isLogout
                    weakSelf!.reload()
                }
            }
        }
    }
    
    func attachDelegate(delegate:CommonUIWebViewDelegate)
    {
        self.delegates.append(delegate)
    }
    
    func detachAllDelegate()
    {
        self.delegates.removeAll(keepCapacity: false)
    }
    
    func checkLogin() -> Bool
    {
        return false
    }
    
    dynamic func optionalBool(request:NSURLRequest,navigationType: UIWebViewNavigationType) -> Bool
    {
        return true
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        if request.URL == nil || request.URL?.absoluteString.length == 0 {
            return false
        }
        let newUrlString:String = request.URL!.absoluteString
        if newUrlString == "about:blank" {
            return true
        }
        if newUrlString.noHttpScheme()
        {
            return false
        }
        
        // 是否是iframe到请求
        var isIframe:Bool = request.URL!.absoluteString != request.mainDocumentURL!.absoluteString
        if self.newCurrentUrl.substringByRemoveUrlScheme().hasPrefix("//wq.jd.com/bases/msggw/Mpage")
        {
            isIframe = true
        }
        
        weak var weakSelf = self
        
        // 页面连接
        self.isLoadErrPage = false
        
        DPrintln("shouldStartLoadWithRequest old:\(webView.request?.URL)")
        DPrintln("shouldStartLoadWithRequest new:\(request.URL);\(navigationType.rawValue)")
        //锚点
        let isMark:Bool = self.isMark(newUrlString)
        
        var strOldUrl:String = ""
        if let temp =  self.request?.URL?.absoluteString, let tempUrl = self.request?.URL {
            strOldUrl = temp
        }
        
        if  isIframe == false
            && self.lastRequestUrlString != newUrlString
            && (isMark == false)
            && navigationType == UIWebViewNavigationType.LinkClicked
        {
            AppDelegate.sharedApp()?.mainController?.setToolbarURL(newUrlString)
        }
        
        if isIframe == false {
            self.onShouldStartLoadWithRequest?(webView: weakSelf, request: request, navigationType: navigationType)
            self.lastRequestUrlString = newUrlString
            request.setAllowLoad(true)
            for item in self.delegates
            {
                item.webView?(weakSelf, shouldStartLoadWithRequest:request, navigationType:navigationType)
            }
            self.hasStartLoad = true
        }
        
        shouldStartUrl = newUrlString;
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        DPrintln("webViewDidStartLoad = \(webView.request?.URL?.absoluteString);\(shouldStartUrl))")
        if let newUrlString = webView.request?.URL?.absoluteString where newUrlString.length > 0
        {            
            weak var weakSelf = self
            
            self.onWebViewDidStartLoad?(webView: weakSelf)
            
            for item in self.delegates
            {
                item.webViewDidStartLoad?(weakSelf)
            }
            self.refreshView?.endRefreshing()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        webView.switchLog()
        webView.switchAlert()
        
        if let absoluteString = webView.request?.URL?.absoluteString
        {
            self.urlLoadHistoryDict[absoluteString] = true
        }
        
        weak var weakSelf = self
        self.onWebViewDidFinishLoad?(webView: weakSelf)
        
        for item in self.delegates
        {
            item.webViewDidFinishLoad?(weakSelf)
        }
        
        self.refreshView?.endRefreshing()
        
        // 检查cookie
        WXSQHttpCookieManager.initalizedCookie()
        
        // 禁用长按弹出框
        webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitTouchCallout='none';")
        // 禁用长按手势
        disableLongPressGesturesForView(webView)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?)
    {
        let resp = NSURLCache.sharedURLCache().cachedResponseForRequest(webView.request!)

        DPrintln("witherror =\(error);\(resp?.response)")
        weak var weakSelf = self
        self.refreshView?.endRefreshing()
        if error?.code != -999 && error?.code != 102  &&  error?.code != 101{
            self.hasStartLoad = false
        }
        self.onDidFailLoadWithError?(webView: weakSelf, error: error!)
        
        for item in self.delegates
        {
            item.webView?(weakSelf, didFailLoadWithError: error!)
        }
        if error?.code == -1009 {
            MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("似乎与网络断开连接")
        }
        // err
        //16.1.28 杜永超 添加-1004和-1009
        //-1009是断网后提示"似乎与网络断开链接"
        //-1004是某些情况下“http://113.57.230.90/test/5m.jpg未能连接到服务器”
        if self.isLoadErrPage == false && (error?.code != -999 && error?.code != 102   &&  error?.code != 101 && error?.code != -1009 && error?.code != -1004)
        {
            self.isLoadErrPage = true
            if let filePath:String = NSBundle.mainBundle().pathForResource("err", ofType: "html"),
                let errHtml = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            {
                self.loadHTMLString(errHtml, baseURL: nil)
            }
        }
    }
    
    private func gotoVC(newUrl newUrlString:String,oldUrl strOldUrl:String) -> Bool {
        let vc = ViewHelper.getFirstNavigationControllerContainer(self)
        
        let newVebViewVC = CommonWebViewController(nibName: "CommonWebViewController", bundle: nil)
        
        newVebViewVC.entryUrl = newUrlString as String
        newVebViewVC.lastWebViewUrl = strOldUrl
        newVebViewVC.hidesBottomBarWhenPushed = true
        
        newVebViewVC.sidebarDelegate = AppDelegate.sharedApp()?.mainController
        
        vc?.navigationController?.pushViewController(newVebViewVC, animated: true)
        return false
    }
    
    // 判断是否是锚点
    func isMark(newURL:String) -> Bool {
        
        var oldURL:String = ""
        
        if let oldURLValue:String = self.request?.URL?.absoluteString {
            oldURL = oldURLValue
        }
        
        if oldURL == "" {
            oldURL = self.lastRequestUrlString
        }
        
        // 取#前面
        var indexRange: NSRange = NSString(string: oldURL).rangeOfString("#")
        if indexRange.location != NSNotFound {
            oldURL = NSString(string: oldURL).substringToIndex(indexRange.location)
        }
        
        indexRange = NSString(string: newURL).rangeOfString("#")
        if indexRange.location != NSNotFound {
            return newURL.hasPrefix(oldURL)
        }
        
        return false
    }
    
    private func updateStatusControl() {
        if self.enableHeadRefresh {
            self.initRefreshHeaderView()
        }
        else
        {
            self.scrollView.removeHeader()
        }
    }
    
    func loadUrl(urlString:String) {
        if urlString.length == 0 {
            self.refreshView?.endRefreshing()
            return
        }
        if self.currentUrl == urlString && (NSDate().timeIntervalSince1970 - self.lastRefreshTimestamp) < 2.0 {
            self.refreshView?.endRefreshing()
            return
        }
        
        self.lastRefreshTimestamp = NSDate().timeIntervalSince1970
        self.currentUrl = urlString
        self.lastRequestUrlString = urlString
        self.newCurrentUrl = urlString
        self.innerLoadRequest(urlString)
    }
    
    private func innerLoadRequest(urlString:String) {
        if let nsurlValue:NSURL = NSURL(string: urlString) {
            let muRequest:NSMutableURLRequest = NSMutableURLRequest(URL: nsurlValue)
            if self.lastWebViewUrl != ""
            {
                muRequest.setValue(self.lastWebViewUrl, forHTTPHeaderField: "Referer")
            }
            self.loadRequest(muRequest)
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        for item in self.delegates
        {
            item.scrollViewDidScroll?(scrollView)
        }
        self.scrollViewDidScroll?(scrollView: scrollView)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
    }
    
    dynamic func setScrollDecelerate(rate:CGFloat)
    {
        self.scrollView.decelerationRate = rate
    }
    
    func isLoadedCurrentUrl(urlString:String) -> Bool {
        if let f = self.urlLoadHistoryDict[urlString] where f != nil  {
            return f!
        }
        return false
    }
    
    func reloadWebView() {
        self.lastRefreshTimestamp = 0.0
        self.loadUrl(self.currentUrl)
    }
    
    func disableLongPressGesturesForView(view: UIView) {
        for subview in view.subviews {
            if let gestures = subview.gestureRecognizers {
                for gesture in gestures {
                    if gesture is UILongPressGestureRecognizer {
                        gesture.enabled = false
                    }
                }
            }
            disableLongPressGesturesForView(subview)
        }
    }
    
    
}

extension CommonUIWebView {
    
    //MARK:-
    static func getTargetOfSpecifyKeyFromURL(url:String) -> (String?,String?,String) {
        var dapeiId:String? = nil
        var dapeiType:String? = nil
        var type:String = ""
        let temp = url.componentsSeparatedByString("?")
        if temp.count > 1 {
            if  let params:[String] = temp.last?.componentsSeparatedByString("&") {
                
                for param in params {
                    
                    if param.hasPrefix("id=") {
                        
                        let keyValues = param.componentsSeparatedByString("=")
                        if keyValues.count == 2 {
                            if let id = keyValues.last {
                                dapeiId = id
                            }
                        }
                    }
                    else if param.hasPrefix("dapeitype=") { // 标识是否搭配类型   1 个人搭配  2 商家搭配  3 搭一下
                        let keyValues = param.componentsSeparatedByString("=")
                        if keyValues.count == 2 {
                            if let t = keyValues.last {
                                dapeiType = t
                                type = "dapeitype"
                            }
                        }
                    }
                    else if param.hasPrefix("publish=") { // 标识是否已发布  1 已发布 0 只保存未发布
                        let keyValues = param.componentsSeparatedByString("=")
                        if keyValues.count == 2 {
                            if let t = keyValues.last {
                                dapeiType = t
                                type = "publish"
                            }
                        }
                    }
                }
            }
        }
        return (dapeiId,dapeiType,type)
    }

}

class NewWebView:CommonUIWebView {
    
    
    override func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return super.webView(webView, shouldStartLoadWithRequest: request, navigationType: navigationType)
        
    }
}

enum CollocationType {
    case createAndPublished, createAndUnpublished, collectAndPrivatePublished ,collectAndPrivateUnpublished , collectAndDayixia
    case collocation(String, String, String,Bool)
    
    static func getTargetOfSpecifyKeyFromURL(url:String)  -> CollocationType {
        var dapeiId:String = ""
        var dapeiType:String = ""
        var publish:String = ""
        var needShowMsg:Bool = false
        let temp = url.componentsSeparatedByString("?")
        if temp.count > 1 {
            if  let params:[String] = temp.last?.componentsSeparatedByString("&") {
                
                for param in params {
                    
                    if param.hasPrefix("id=") {
                        
                        let keyValues = param.componentsSeparatedByString("=")
                        if keyValues.count == 2 {
                            if let id = keyValues.last {
                                dapeiId = id
                            }
                        }
                    }
                    else if param.hasPrefix("dapeitype=") { // 标识是否搭配类型   1 个人搭配  2 商家搭配  3 搭一下
                        let keyValues = param.componentsSeparatedByString("=")
                        if keyValues.count == 2 {
                            if let t = keyValues.last {
                                dapeiType = t
                            }
                        }
                    }
                    else if param.hasPrefix("publish=") { // 标识是否已发布  1 已发布 0 只保存未发布
                        let keyValues = param.componentsSeparatedByString("=")
                        if keyValues.count == 2 {
                            if let t = keyValues.last {
                                publish = t
                            }
                        }
                    }
                    else if param.hasPrefix("needShowMsg"){
                        let keyValues = param.componentsSeparatedByString("=")
                        if keyValues.count == 2 {
                            if let t = keyValues.last {
                                needShowMsg = (t as NSString).boolValue
                            }
                        }
                    }
                }
            }
        }
        return CollocationType.collocation(dapeiId, dapeiType, publish,needShowMsg)
    }
}