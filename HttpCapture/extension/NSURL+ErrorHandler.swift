//
//  NSURL+ErrorHandler.swift
//  weixindress
//
//  Created by duyongchao on 15/9/23.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

import UIKit

extension NSURL {

    func WQresourceValuesForKeys(keys: [String], error:NSErrorPointer) -> [String : AnyObject]? {
        var re = [String : AnyObject]()
        do {
            re = try self.resourceValuesForKeys(keys)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
            return nil
        }
        return re
    }
}
extension NSJSONSerialization {
    class func WQdataWithJSONObject(obj: AnyObject, options opt: NSJSONWritingOptions, error: NSErrorPointer) -> NSData? {
        var re:NSData?
        do {
            re = try self.dataWithJSONObject(obj, options: opt)
        } catch let err as NSError {
            if error != nil {
                error.memory = err
            }
            return nil
        }
        return re
    }
    class func WQJSONObjectWithData(data: NSData, options opt: NSJSONReadingOptions, error: NSErrorPointer) -> AnyObject? {
        var re:AnyObject?
        if let da = data.exchangeObject()
        {
            do {
                re = try self.JSONObjectWithData(da, options: opt)
            } catch let err as NSError {
                if error != nil {
                    error.memory = err
                }
                return nil
            }
            return re
        }
        else{
            return nil
        }
    }
    
   
}