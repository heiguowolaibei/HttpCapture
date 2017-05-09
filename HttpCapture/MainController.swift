//
//  ViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/12.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class MainController: CaptureBaseViewController {
    var webView:UIWebView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    func config()  {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        webView = UIWebView(frame:self.view.bounds)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBar.hidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

