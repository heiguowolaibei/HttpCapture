//
//  DictionaryExt.swift
//  weixindress
//
//  Created by kevin on 15/8/28.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation

func isEqualToDictionary(lhs: [String: AnyObject], rhs: [String: AnyObject] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqualToDictionary(rhs)
}

extension Dictionary {
    
    //MARK:遍历加入Dictionary的key和value值
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
//    func joinKeyAndValueWithSpecial(join joinString:String = ";") -> String! {
//        let d:Any = self.getMirror().value
//        if d is [String:AnyObject] {
//            let dic:[String:AnyObject] = d as! [String:AnyObject]
//            var rs:String! = nil
//            var allKeys = Array(self.keys) //.getMirror().value
//            var allValues = Array(self.values)
//            if allValues.getMirror().value is [String] && allKeys.getMirror().value is [String]  {
//                var keys:[String] = allKeys.getMirror().value as! [String]
//                rs = keys.reduce("", combine: { (r:String, v:String) -> String in
//                    if keys.first == v {
//                        if let d: AnyObject = dic[v] {
//                            return v + "=" + "\(d)" + r
//                        }
//                    }
//                    else {
//                        if let d: AnyObject = dic[v] {
//                            return v + "=" + "\(d)" + joinString + r
//                        }
//                    }
//                    return v + "=" + "" + joinString + r
//                })
//            }
//            return rs
//        }
//        return nil
//    }
    
}