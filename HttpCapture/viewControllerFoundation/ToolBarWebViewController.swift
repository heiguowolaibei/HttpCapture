//
//  ToolBarWebViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/24.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit
import Foundation

@objc class ToolBarWebViewController: CommonWebViewController,UITextFieldDelegate {
    var activity = [WeixinSessionActivity(), WeixinTimelineActivity()];
    @objc var textfield = UITextField()
    var goBtn:UIButton?
    let goWidth:CGFloat = 40;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSearchField()
    }
    
    override func configWebView() {
        super.configWebView()
        
        self.webView?.scrollViewDidScroll = {[weak self](scrollView: UIScrollView) -> Void in
            self?.textfield.resignFirstResponder()
        }
        self.webView?.onWebViewDidFinishLoad = {[weak self](webView:CommonUIWebView?) -> Void in
            self?.preSnapShotView?.removeFromSuperview()
            if let url = webView?.request?.URL?.absoluteString where url != "about:blank" && url.length > 0
            {
                self?.textfield.text = url
            }
        }
    }
    
    override func useDefaultBackButton() -> Bool {
        return false;
    }
    
    func addSearchField() {
        textfield.frame = CGRectMake(50, 20 + 6, self.view.width - 50 - 5 - goWidth - 5, 34)
        textfield.backgroundColor = UIColor.fromRGB(0xeeeeee)
        textfield.keyboardType = UIKeyboardType.WebSearch
        textfield.delegate = self;
        textfield.text = AppConfiguration.Urls.guideUrl
        textfield.layer.cornerRadius = 3;
        let cLeftV = UIView(frame: CGRectMake(0, 0, 5, 5))
        cLeftV.backgroundColor = UIColor.clearColor()
        textfield.leftView = cLeftV
        
        let rightV = UIButton(frame: CGRectMake(textfield.width - 30, 2, 30, 30))
        rightV.setImage(CommonImageCache.getImage(named: "标签删除"), forState: UIControlState.Normal)
        rightV.addTarget(self, action: "reset", forControlEvents: UIControlEvents.TouchUpInside)
        textfield.rightView = rightV
        textfield.rightViewMode = .WhileEditing
        
        textfield.leftViewMode = .Always
        textfield.layer.masksToBounds = true
        self.navigationBar.addSubview(textfield)
        
        goBtn = UIButton(frame: CGRectMake(self.view.width - 5 - goWidth,20+6,goWidth,34))
        goBtn?.setTitle("go", forState: UIControlState.Normal)
        goBtn?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        goBtn?.backgroundColor = UIColor.colorWithRGB(red: 0, green: 122, blue: 255)
        goBtn?.layer.cornerRadius = 3;
        goBtn?.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        goBtn?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        goBtn?.addTarget(self, action: "goto", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationBar.addSubview(goBtn!)
    }
    
    func reset() {
        textfield.text = ""
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        textfield.resignFirstResponder()
    }
    
    func goto()  {
        if let tt = textfield.text
        {
            self.entryUrl = tt
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textfield.text?.length == 0 {
            textfield.text = "http://"
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
        self.goto()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
//    func bar4()  {
//        let vc = RecordViewController()
//        vc.targetVC = self
//        vc.histories = HttpCaptureManager.shareInstance().histories
//        let pan = PanNavigationController(rootViewController: vc)
//        self.navigationController?.presentViewController(pan, animated: true, completion: {
//            
//        })
//    }
    
//    func bar5()  {
//        self.webView?.stopLoading()
//        self.webView?.reloadWebView()
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textfield.frame = CGRectMake(50, 20 + 6, self.view.width - 50 - 5 - goWidth - 5, 34)
        goBtn?.frame = CGRectMake(self.view.width - 5 - goWidth,20+6,goWidth,34)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        toolBar.frame = CGRectMake(0, self.view.height - 49, self.view.width, 49)
    }
    
    func space() {
        
    }

}
