//
//  ConsoleLogViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/20.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class ConsoleLogViewController: SearchViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func rightButtonClick(btn:UIButton) {
        self.text = ""
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory.stringByAppendingString("/consoleLog.txt")
        FileHelper.FileManager.WQremoveItemAtPath(pathForLog, error: nil)
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
