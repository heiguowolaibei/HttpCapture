//
//  CusWebViewProgress.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/19.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

@objc class CusWebViewProgress: NJKWebViewProgress {

    override func webViewDidStartLoad(webView: UIWebView) {
        if webView.request?.URL?.absoluteString.length == 0 || webView.request?.URL?.absoluteString == "about:blank"
        {
            if self.webViewProxyDelegate.respondsToSelector("webViewDidStartLoad:")
            {
                self.webViewProxyDelegate.webViewDidStartLoad?(webView)
            }
            return
        }
        
        super.webViewDidStartLoad(webView)
    }
    
    override func webViewDidFinishLoad(webView: UIWebView) {
        if webView.request?.URL?.absoluteString.length == 0 || webView.request?.URL?.absoluteString == "about:blank"
        {
            if self.respondsToSelector("completeProgress")
            {
                self.performSelector("completeProgress", withObject: nil)
            }
            if self.webViewProxyDelegate.respondsToSelector("webViewDidFinishLoad:")
            {
                self.webViewProxyDelegate.webViewDidFinishLoad?(webView)
            }
            return
        }
        
        super.webViewDidFinishLoad(webView)
    }
    
}
