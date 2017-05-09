//
//  Array+extension.swift
//  weixindress
//
//  Created by liuyihao1216 on 15/11/13.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

import Foundation

extension Array {
    mutating func removeObject <U: Equatable> (object: U) {
        if self.count > 0{
            for i in 0..<self.count {
                if let element = self[i] as? U {
                    if element == object {
                        self.removeAtIndex(i)
                        break
                    }
                }
            }
        }
    }
    
    func subarrayWithRange(range:NSRange) -> Array<Element>?{
        if range.location + range.length > self.count || range.length < 0{
            return nil
        }
        
        let start = self.startIndex + range.location
        let end = self.startIndex.advancedBy(range.length + range.location)
        let obj = self[Range(start: start, end: end)]
        return Array(obj)
    }
}
