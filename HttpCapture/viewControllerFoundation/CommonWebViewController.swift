//
//  CommonWebViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/13.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit
import Foundation
import JavaScriptCore

class UITitleView: UIView {
    
    override var frame:CGRect{
        get {
            return super.frame
        }
        
        set {
            super.frame = CGRectMake(0, 20, UIScreen.mainScreen().applicationFrame.width, 44)
        }
    }
}
class UITitleView2: UIView {
    var layoutSubview:(() -> Void)?
    
    override var frame:CGRect{
        get {
            return super.frame
        }
        
        set {
            super.frame = CGRectMake(0, 0, UIScreen.mainScreen().applicationFrame.width, 44)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubview?()
    }
}

class SnapShotMsg:NSObject{
    var msgUrl:String?
    var snapShotView:UIView?
    
    convenience init(msgUrl:String,snapShotView:UIView)
    {
        self.init()
        self.msgUrl = msgUrl
        self.snapShotView = snapShotView
    }
}

enum CommonWebType {
    case Brand
    case Dapei
    case ShoppingCart
    case Person
}

@objc class CommonWebViewController: CaptureBaseViewController,CommonUIWebViewDelegate,UIActionSheetDelegate
{
    var statusBackground: UIView?
    weak var webView: CommonUIWebView?

    private var viewHeaderPlace: UITitleView = UITitleView()
    private var currentHeaderStyleName:String = ""
    private var defaultLinkTarget:LinkTarget = LinkTarget.None
    
    var hiddenCustomNavigationBar = false
    
    var hasToolBar = true
    var barItem1 = UIBarButtonItem(customView: UIView())
    var barItem2 = UIBarButtonItem(customView: UIView())
    var barItem3 = UIBarButtonItem(customView: UIView())
    var barItem4 = UIBarButtonItem(customView: UIView())
    var barItem5 = UIBarButtonItem(customView: UIView())
    var barItem6 = UIBarButtonItem(customView: UIView())
    var toolBar = UIToolbar()
    
    var bHiddenNavigationbar = false
    var bShowBlackStatusBar = false
    var bTraneparentNavigationBar = false
    
    // 最高优先级，如果有值，则忽略url中的样式
    var headerStyleName:String = ""
    var hiddenBackBtn:Bool = false
    var hiddenBackBtn2:Bool = false
    @objc var isBlackNavi:Bool = false;
    var redirectResponses = [NSURLResponse]()
    var actionSheet:UIActionSheet?
    var isFirst = true
    var initHomeUrl = false

    @objc var snapShotsArray = Array<SnapShotMsg>()
        {
        didSet{
            
        }
    }
    var isSwipingBack = false
    var preSnapShotView:UIView?
    
    // 首页地址
    private var _entryUrl:String = ""
    var entryUrl:String
        {
        get
        {
            return _entryUrl
        }
        set {
            var url = newValue
            
            if !newValue.hasPrefix("http://") && !newValue.hasPrefix("https://")
            {
                url = "http://" + newValue
            }
            
            _entryUrl = url
            if self.isViewLoaded() {
                self.internalLoadUrl(self._entryUrl)
            }
            self.preSnapShotView?.removeFromSuperview()
            HttpCaptureManager.shareInstance().appendHistoryMsg(self._entryUrl, date: NSDate())
            HttpCaptureManager.shareInstance().appendPageMsg(NSDate())
            HttpCaptureManager.shareInstance().currentUrl = self._entryUrl
            AppDelegate.sharedApp()?.mainController?.changeTitle(self._entryUrl)
        }
    }
    
    var lastWebViewUrl:String = ""
    
    deinit{
        self.removeAllHeaderElements()
        
        if self.webView != nil {
            self.webView?.clear()
            
            self.webView?.removeFromSuperview()
            
            self.webView = nil
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func initialize() {
        super.initialize()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func onReLayoutScrollBrowserViewFrame(){
        if let web = self.webView {
            for subView in web.scrollView.subviews {
                var subFrame:CGRect = subView.frame
                if subView.height >= web.height && subView.width >= web.width {
                    var tabheight:CGFloat = 0
                    if self.tabBarController != nil {
                        tabheight = (self.tabBarController!.tabBar as UITabBar).frame.size.height;
                    }
                    subFrame.size.height = WXDevice.height - CGFloat(self.view.origin.y) - tabheight
                    (subView ).frame = subFrame
                }
            }
        }
    }
    
    func isRidirectURL(url:String) -> Bool {
        for item in redirectResponses
        {
            if let surl = item.URL?.absoluteString
            {
                if surl.containsString(url) || url.containsString(surl)
                {
                    return true
                }
            }
        }
        return false;
    }
    
    func appendRedirectResponse(res:NSURLResponse){
        if let res = res.mutableCopy() as? NSURLResponse
        {
            redirectResponses.append(res)
        }
    }
    
    override func hasCustomNavigationBar() -> Bool
    {
        return true
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if self.bShowBlackStatusBar
        {
            return UIStatusBarStyle.LightContent
        }
        switch self.navigationBarStyle(){
            case  BaseNavigtionStyle.White:
                return UIStatusBarStyle.Default
            case  BaseNavigtionStyle.Black:
                return UIStatusBarStyle.LightContent
            case  BaseNavigtionStyle.Clear:
                return UIStatusBarStyle.LightContent
            case  BaseNavigtionStyle.Gradient:
                return UIStatusBarStyle.LightContent
            default:
                return UIStatusBarStyle.Default
        }
    }
    
    func resetContentInset()
    {
        guard let web = self.webView else
        {
            return
        }
        
        self.navigationBar.hidden = self.bHiddenNavigationbar
        self.statusBackground?.hidden = !self.bShowBlackStatusBar
        
        let orInset = web.scrollView.contentInset
        var newInset = UIEdgeInsetsZero
        if !self.bHiddenNavigationbar
        {
            if self.bTraneparentNavigationBar
            {
                newInset = UIEdgeInsetsMake(0 + (self.bShowBlackStatusBar ? 20 : 0), orInset.left, orInset.bottom, orInset.right)
            }
            else
            {
                newInset = UIEdgeInsetsMake(64, orInset.left, orInset.bottom, orInset.right)
            }
        }
        else
        {
            newInset = UIEdgeInsetsMake(0 + (self.bShowBlackStatusBar ? 20 : 0), orInset.left, orInset.bottom, orInset.right)
        }
        web.scrollView.contentInset = newInset
        web.scrollView.scrollIndicatorInsets = newInset
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.resetContentInset()
        toolBar.frame = CGRectMake(0, self.view.height - 49, self.view.width, 49)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configWebView()
        
        self.internalLoadUrl(self.entryUrl)
        self.configToolBar(false)
    }
    
    func configWebView() {
        self.webView = CommonUIWebView(frame: self.view.bounds)
        self.view.addSubview(self.webView!)
        self.webView?.fatherViewControler = self
        self.webView?.onShouldStartLoadWithRequest = {[weak self](webView: CommonUIWebView?, request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Void in
            guard let newself = self else {return}
            
            switch navigationType {
            case .LinkClicked:
//                newself.pushCurrentSnapshotView(request,webView: webView)
                break;
            case .FormSubmitted:
//                newself.pushCurrentSnapshotView(request,webView: webView)
                break;
            case .BackForward:
                break
            case .Reload:
                break
            case .FormResubmitted:
                break
            case .Other:
//                newself.pushCurrentSnapshotView(request,webView: webView)
                break;
            default:
                break
            }
        }
        self.webView?.onDidFailLoadWithError = {[weak self](webView: CommonUIWebView?, error: NSError) -> Void in
            self?.preSnapShotView?.removeFromSuperview()
        }
    }
    
    func bar1()  {
        if self.webView?.canGoBack == true {
            (barItem1.customView as? UIButton)?.setImage(CommonImageCache.getImage(named: "前一步"), forState: UIControlState.Normal)
            self.webView?.goBack()
        }
        else{
            
        }
    }
    
    func bar2()  {
        if self.webView?.canGoForward == true {
            (barItem2.customView as? UIButton)?.setImage(CommonImageCache.getImage(named: "后一步"), forState: UIControlState.Normal)
            self.webView?.goForward()
        }
        else{
            
        }
    }
    
    func bar3() {
        self.internalLoadUrl(AppConfiguration.Urls.guideUrl)
    }
    
    @objc func backToPage(index:Int)
    {
        if let delegate = self.sidebarDelegate, let indexpath = self.sidebarDelegate?.getSearchWebControllerIndexPath?()
        {
            delegate.selectIndexPath?(indexpath, animationFinishBlock: { (finish) in
                
            })
        }
        
        let path = index == 0 ? AppConfiguration.Urls.guideUrl : AppConfiguration.Urls.helpUrl
        self.internalLoadUrl(path)
    }
    
    func bar4() {
        let previewVC = PreviewViewController()
        HttpCaptureManager.shareInstance().getAllEntries { (re) in
            previewVC.entries = re;
            previewVC.configTempEntries()
        }
        let panVC = UINavigationController(rootViewController: previewVC)
        self.navigationController?.presentViewController(panVC, animated: true, completion: nil)
    }
    
    func bar5() {
        let uploadVC = UploadViewController()
        let panVC = UINavigationController(rootViewController: uploadVC)
        self.navigationController?.presentViewController(panVC, animated: true, completion: nil)
        HttpCaptureManager.shareInstance().saveHAR()
    }
    
    func bar6() {
//        if let filePath:String = NSBundle.mainBundle().pathForResource("test", ofType: "html"),
//            let errHtml = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
//        {
//            self.webView?.loadHTMLString(errHtml, baseURL: nil)
//        }
//        return;
        
        let shareVC = ShareViewController()
        let panVC = UINavigationController(rootViewController: shareVC)
        self.navigationController?.presentViewController(panVC, animated: true, completion: nil)
        HttpCaptureManager.shareInstance().saveHAR()
    }
    
    func configToolBar(bHidden:Bool) {
        if hasToolBar,var rect = webView?.frame {
            if !bHidden {
                rect.size.height -= 49
                webView?.frame = rect;
            }
            
            toolBar.frame = CGRectMake(0, self.view.height - 49, self.view.width, 49)
            toolBar.barTintColor = UIColor.colorWithRGB(red: 244, green: 244, blue: 244)
            
            let widthHeight:CGFloat = 30
            
            let spaceBar1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "space")
            
            let btn1 = UIButton(frame: CGRectMake(0,0,widthHeight,widthHeight))
            btn1.setImage(CommonImageCache.getImage(named: "前一步"), forState: UIControlState.Normal)
            btn1.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
            btn1.addTarget(self, action: "bar1", forControlEvents: UIControlEvents.TouchUpInside)
            barItem1 = UIBarButtonItem(customView: btn1)
            
            let spaceBar2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "space")
            
            let btn2 = UIButton(frame: CGRectMake(0,0,widthHeight,widthHeight))
            btn2.setImage(CommonImageCache.getImage(named: "后一步"), forState: UIControlState.Normal)
            btn2.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
            btn2.addTarget(self, action: "bar2", forControlEvents: UIControlEvents.TouchUpInside)
            barItem2 = UIBarButtonItem(customView: btn2)
            
            let spaceBar3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "space")
            
            let btn3 = UIButton(frame: CGRectMake(0,0,widthHeight,widthHeight))
            btn3.setImage(CommonImageCache.getImage(named: "main_navi_brand_normal"), forState: UIControlState.Normal)
            btn3.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            btn3.addTarget(self, action: "bar3", forControlEvents: UIControlEvents.TouchUpInside)
            barItem3 = UIBarButtonItem(customView: btn3)
            
            let spaceBar4 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "space")
            
            let btn4 = UIButton(frame: CGRectMake(0,0,widthHeight,widthHeight))
            btn4.setImage(CommonImageCache.getImage(named: "feed_vote_icon"), forState: UIControlState.Normal)
            btn4.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            btn4.addTarget(self, action: "bar4", forControlEvents: UIControlEvents.TouchUpInside)
            barItem4 = UIBarButtonItem(customView: btn4)
            
            let spaceBar5 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "space")
            
            let btn5 = UIButton(frame: CGRectMake(0,0,widthHeight,widthHeight))
            btn5.setImage(CommonImageCache.getImage(named: "发布按钮未选中"), forState: UIControlState.Normal)
            btn5.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
            btn5.addTarget(self, action: "bar5", forControlEvents: UIControlEvents.TouchUpInside)
            barItem5 = UIBarButtonItem(customView: btn5)
            
            let spaceBar6 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "space")
            
            let btn6 = UIButton(frame: CGRectMake(0,0,widthHeight,widthHeight))
            btn6.setImage(CommonImageCache.getImage(named: "feed_share_icon"), forState: UIControlState.Normal)
            btn6.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
            btn6.addTarget(self, action: "bar6", forControlEvents: UIControlEvents.TouchUpInside)
            barItem6 = UIBarButtonItem(customView: btn6)
            
            let spaceBar7 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "space")
            
            self.toolBar.items = [spaceBar1,barItem1,spaceBar2,barItem2,spaceBar3,barItem3,spaceBar4,barItem4,spaceBar5,barItem5,spaceBar6,barItem6,spaceBar7];
            
            self.view.addSubview(toolBar)
            toolBar.hidden = bHidden;
        }
    }
    
    override func rightButtonClick(item: UIButton) {
        if self.navigationController?.viewControllers.count > 1 {
            actionSheet?.removeFromSuperview()
            actionSheet?.showInView(self.view)
        }
    }
    
    func configUI()  {
        if self.navigationController?.viewControllers.count > 1 {
            rightBtn.frame = CGRectMake(0, 0, 44, 44)
            rightBtn.contentHorizontalAlignment = .Right
            rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
            rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
            rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
            rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
            rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
            rightBtn.setImage(CommonImageCache.getImage(named: "分类黑色"), forState: UIControlState.Normal)
            rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let rightItem = UIBarButtonItem(customView: rightBtn)
//            self.navigationItem.rightBarButtonItem = rightItem
        }
        
//        actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
//        if let titles = AppDelegate.sharedApp()?.itemTitles
//        {
//            for title in titles
//            {
//                if title == "浏览器" {
//                    continue
//                }
//                actionSheet?.addButtonWithTitle(title)
//            }
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.webView?.viewWillAppear(animated)
        
        self.viewHeaderPlace.frame = CGRectMake(0, 20, UIScreen.mainScreen().applicationFrame.width, 44)
        // 总是隐藏默认返回按钮
//        let placeView = UIView(frame: CGRectMake(0, 0, 0, 0))
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:placeView);
        self.navigationItem.backBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRectZero))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.webView?.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.navigationController?.isKindOfClass(BaseNavigationController.self) == true
        {
            (self.navigationController as! BaseNavigationController).newViewControllerDidAppear()
        }
        self.isFirst = false
        self.statusBackground?.backgroundColor = UIColor.clearColor()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        
        self.navigationBar.getBottomImageOfNavigationBar()
    }
    
    func hiddenNaivi(bHidden:Bool,bHiddenStatusBar:Bool){
        if webView?.refreshView != nil && self.webView?.refreshView?.state != MJRefreshHeaderStateIdle
        {
            self.webView?.scrollView.mj_header.endRefreshing()
        }
        
        bHiddenNavigationbar = bHidden
        self.resetContentInset()
    }
    
    private func removeAllHeaderElements() {
        self.viewHeaderPlace.removeAllSubviews()
        
        if self.webView != nil {
            self.webView?.detachAllDelegate()
        }
    }
    
    private func addGradientLayerToNavigationBar() {
        if let layView = self.navigationBar.overlay {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRectMake(0, 0, WXDevice.width, 64)
            gradientLayer.borderWidth = 0.0
            gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.6).CGColor,UIColor.clearColor().CGColor]
            gradientLayer.locations = [0.0,1.0]
            gradientLayer.startPoint = CGPointMake(0.5, 0.0)
            gradientLayer.endPoint = CGPointMake(0.5, 1.0)
            layView.layer.addSublayer(gradientLayer)
        }
    }
    
    private func removeGradientLayerFromNavigationBar() {
        if let panNav = self.navigationController as? PanNavigationController, layers = panNav.navigationBar.overlay?.layer.sublayers
        {
            for layer in layers {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func pushCurrentSnapshotView(request: NSURLRequest,webView:UIWebView?)
    {
        var lastRequest:String? = nil;
        if let last = self.snapShotsArray.last {
            lastRequest = last.msgUrl
        }
        if let fragment = request.URL?.fragment,let surl = request.URL?.absoluteString,let webviewurl = webView?.request?.URL?.absoluteString
        {
            let nonFragmentURL = surl.stringByReplacingOccurrencesOfString("#" + fragment, withString: "")
            if nonFragmentURL == webviewurl {
                return
            }
        }
        if (request.URL?.absoluteString == "about:blank")
        {
            return
        }
        //如果url一样就不进行push
        if (lastRequest == request.URL?.absoluteString)
        {
            return
        }
        
        if let currentSnapShotView = self.webView?.snapshotViewAfterScreenUpdates(false), let s = request.URL?.absoluteString
        {
            self.snapShotsArray.append(SnapShotMsg(msgUrl: s, snapShotView: currentSnapShotView))
        }
    }
    
    func swipePanGestureHandler(panGesture: UIPanGestureRecognizer)
    {
        let translation = panGesture.translationInView(self.webView)
        let location = panGesture.locationInView(self.webView)
        if panGesture.state == .Began {
            if location.x <= 50 && location.x > 0 {
                //开始动画
                self.startPopSnapshotView()
            }
        }
        else if panGesture.state == .Cancelled || panGesture.state == .Ended {
            self.endPopSnapShotView()
        }
        else if panGesture.state == .Changed {
            self.popSnapShotView(withPanGestureDistance: translation.x)
        }
    }
    
    func startPopSnapshotView() {
        if self.isSwipingBack {
            return
        }
        if self.webView?.canGoBack == false {
            return
        }
        if self.webView == nil {
            return
        }
        
        self.isSwipingBack = true
        var center = CGPoint(x: self.view.bounds.size.width / 2, y: self.webView!.height / 2)
        if let last = self.snapShotsArray.last
        {
            self.preSnapShotView = last.snapShotView
            center.x -= 60
            self.preSnapShotView?.center = center
            self.view.insertSubview(self.preSnapShotView!, belowSubview: self.webView!)
        }
    }
    
    @objc func clearSnapShotsArray()
    {
        self.snapShotsArray.removeAll()
    }
    
    @objc func replaceWebView(){
        if let webv = self.webView
        {
            let frame = webv.frame
            self.webView?.clear()
            self.webView?.removeFromSuperview()
            self.configWebView()
            self.webView?.frame = frame
        }
    }
    
    func popSnapShotView(withPanGestureDistance distance: CGFloat) {
        if !self.isSwipingBack {
            return
        }
        if distance <= 0 {
            return
        }
        if self.webView == nil || self.preSnapShotView == nil {
            return
        }
        var currentWebViewCenter = CGPoint(x: WXDevice.width / 2, y: self.webView!.height / 2)
        currentWebViewCenter.x += distance
        var prevSnapshotViewCenter = CGPoint(x: WXDevice.width / 2, y: self.webView!.height / 2)
        prevSnapshotViewCenter.x -= (WXDevice.width - distance) * 60 / WXDevice.width
        self.webView?.center = currentWebViewCenter
        self.preSnapShotView?.center = prevSnapshotViewCenter
        
//        DPrintln("distance \(distance);\(currentWebViewCenter.x)")
    }
    
    func endPopSnapShotView() {
        if !self.isSwipingBack {
            return
        }
        self.view.userInteractionEnabled = false
        if self.webView?.center.x >= WXDevice.width {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.webView?.center = CGPoint(x: WXDevice.width / 2, y: self.webView!.height / 2)
                    self.preSnapShotView?.center = CGPoint(x: WXDevice.width / 2, y: self.webView!.height / 2)
                    self.view.bringSubviewToFront(self.preSnapShotView!)
                }, completion: { (finish) in
                    self.webView?.goBack()
                    if self.snapShotsArray.count > 0
                    {
                        self.snapShotsArray.removeLast()
                    }
                    self.view.userInteractionEnabled = true
                    
                    self.isSwipingBack = false;
            })
        }
        else{
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.webView?.center = CGPoint(x: WXDevice.width / 2, y: self.webView!.height / 2)
                    self.preSnapShotView?.center = CGPoint(x: WXDevice.width / 2 - 60, y: self.webView!.height / 2)
                }, completion: { (finish) in
                    self.preSnapShotView?.removeFromSuperview()
                    self.view.userInteractionEnabled = true
                    self.isSwipingBack = false
            })
        }
    }
    
    // about webview
    private func internalLoadUrl(urlString:String){
        if urlString == "" {
            return
        }
        
        self.webView?.lastWebViewUrl = self.lastWebViewUrl
        self.webView?.loadUrl(urlString)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        self.sidebarDelegate?.pushItemViewCtrl?(Int32(buttonIndex))
        
    }
}

































