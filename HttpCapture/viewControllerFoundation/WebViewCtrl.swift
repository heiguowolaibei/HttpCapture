//
//  WebViewCtrl.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/19.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class WebViewCtrl: CaptureBaseViewController {
    var webview :UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webview = CommonUIWebView(frame: self.view.bounds)
        if let filePath:String = NSBundle.mainBundle().pathForResource("test", ofType: "html"),
            let errHtml = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        {
            webview?.loadHTMLString(errHtml, baseURL: nil)
        }
        self.view.addSubview(webview!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
