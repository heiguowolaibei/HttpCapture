//
//  UIView+WXSQView.swift
//  weixindress
//
//  Created by tianjie on 3/23/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation
import UIKit

extension NSData {
    @objc func MD5() -> NSString {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLength)
        CC_MD5(bytes, CC_LONG(length), md5Buffer)
        
        let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
        for i in 0..<digestLength {
            output.appendFormat("%02x", md5Buffer[i])
        }
        let _ = md5Buffer.move()
        md5Buffer.dealloc(digestLength)
        return NSString(format: output)
    }
    
    @objc func objectFromJSONData() -> AnyObject?
    {
        var obj:AnyObject? = nil
        obj = NSJSONSerialization.WQJSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments, error: nil)
        return obj;
    }
    
    @objc func transferToString() -> String{
        var toString:String? = nil
        
        toString = NSString(data: self, encoding: NSUTF8StringEncoding) as? String
        
        if toString == nil {
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            toString = NSString(data: self, encoding: enc) as? String
        }
        
        if toString == nil {
            toString = ""
        }
        
        return toString!
    }
    
    @objc func exchangeObject() -> NSData?{
        var backData = self
        if let str = NSString(data: self, encoding: NSUTF8StringEncoding)
        {
            var ss = str as String
            ss = (ss as NSString).stringByReplacingOccurrencesOfString("\\x", withString: "\\u00")
            
            if let da = ss.dataUsingEncoding(NSUTF8StringEncoding)
            {
                backData = da
            }
        }
        else{
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let s = NSString(data: self, encoding: enc)
            
            if s != nil
            {
                var ss = s as! String
                ss = (ss as NSString).stringByReplacingOccurrencesOfString("\\x", withString: "\\u00")
                
                if let da = ss.dataUsingEncoding(NSUTF8StringEncoding)
                {
                    backData = da
                }
            }
        }
        
        return backData
    }
}
