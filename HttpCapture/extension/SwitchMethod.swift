//
//  SwitchMethod.swift
//  weixindress
//
//  Created by liuyihao1216 on 16/6/24.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

import Foundation


extension NSObject {
    
    @objc func switchMethod(){
        
        
    }
    
    class func redirectLogToDocuments()
    {
        let allPaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory.stringByAppendingString("/consoleLog.txt")
        
        #if DEBUG
        let sd = try?  NSString(contentsOfFile: pathForLog, encoding: NSUTF8StringEncoding)
        #endif
            
        freopen(pathForLog.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stderr)
    }
    
    func switchSwiftMethod(_cls:AnyClass?,originMethod:String,swizzleMethod:String){
        if let cls = _cls
        {
            let originalSelector = Selector(originMethod)
            let swizzledSelector = Selector(swizzleMethod)
            
            let originalMethod = class_getInstanceMethod(cls, originalSelector)
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
            
            let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
}

extension String{
    
}
