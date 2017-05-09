//
//  String+length.swift
//  weixindress
//
//  Created by timothywei on 15/4/23.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation

extension NSString
{
    
    func stringByReplacingPercentEscapesAndPlusUsingEncoding(enc:NSStringEncoding) -> String {
        if let s = self.stringByReplacingPercentEscapesUsingEncoding(enc)
        {
            return s.stringByReplacingOccurrencesOfString("+", withString: " ")
        }
        
        return ""
    }
    
    func imageRetrievalWithWidth(width:Int,height:Int,preItem:String) -> String {
        var urlString : String = ""
        
        var sizeStr = ""
        let hWidth:Int = Int(CGFloat(width) * 2)
        let hHeight:Int = Int(CGFloat(height) * 2)
        if width == 0 && height == 0 {
            sizeStr = "jfs/"
        }
        else {
            sizeStr = "s" + "\(hWidth)" + "x" + "\(hHeight)" + "_jfs/"
        }
        
        if self.hasPrefix("http://img10.360buyimg.com")
        {
            /////dfsd_jsf/
            if let preRegex = try? NSRegularExpression(pattern: "\\w*jfs/", options: NSRegularExpressionOptions.CaseInsensitive)
            {
                return preRegex.stringByReplacingMatchesInString(self as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, self.length), withTemplate:sizeStr)
            }
            
        }
        else{
            if let preRegex = try? NSRegularExpression(pattern: ".*jfs/", options: NSRegularExpressionOptions.CaseInsensitive)
            {
                let str = preRegex.stringByReplacingMatchesInString(self as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, self.length), withTemplate:sizeStr)
                urlString =  "http://img10.360buyimg.com/\(preItem)/\(str)"
            }
        }
        
        return urlString
    }
    
    static func JSONPConvertToJSON(data:NSData) -> NSData? {
        
        return self.JSONPConvertToJSONWithRegularExpression(data, preRegularExpression: "^\\w*\\s*\\{?\\s*\\w*\\s*\\(", suffixRegularExpression: "\\);?$|\\);?\\s*\\}$|\\)\\s*;?\\}\\s*\\w+\\s*\\(\\w*\\)\\s*\\{?[^£]*\\}?$")
    }
    
    static func JSONPConvertToJSONWithRegularExpression(data:NSData,preRegularExpression preRegular:String,suffixRegularExpression suffixRegular:String,unicode:Bool = true) -> NSData? {
        var result:NSData? = nil
        
        var str = NSString(data: data, encoding: NSUTF8StringEncoding)
        if str == nil{
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            str = NSString(data: data, encoding: enc)
        }
        
        if str != nil{
            str = str!.stringByRemovingNewLinesAndWhitespace()
            
            if str == nil{
                return result
            }
            
            if let preRegex = try? NSRegularExpression(pattern: preRegular, options: NSRegularExpressionOptions.CaseInsensitive)
            {
                str = preRegex.stringByReplacingMatchesInString(str! as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, str!.length), withTemplate: "")
                if let sufRegex = try? NSRegularExpression(pattern: suffixRegular, options: NSRegularExpressionOptions.CaseInsensitive)
                {
                    str = sufRegex.stringByReplacingMatchesInString(str! as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, str!.length), withTemplate: "")
                    var tempRS:String = str as! String
                    if unicode {
                        tempRS = tempRS.stringByReplacingOccurrencesOfString("\\x", withString: "\\u00")
                    }
                    result = tempRS.dataUsingEncoding(NSUTF8StringEncoding)
                }
            }
        }
        return result
    }

}

extension NSString {
    func MD5() -> NSString {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLength)
        CC_MD5(UTF8String, CC_LONG(strlen(UTF8String)), md5Buffer)
        
        let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
        for i in 0..<digestLength {
            output.appendFormat("%02x", md5Buffer[i])
        }
        let _ = md5Buffer.move()
        md5Buffer.dealloc(digestLength)
        return NSString(format: output)
    }
    
    func judgeIsImage() -> Bool {
        if self == "image/jpeg" || self == "image/gif" || self == "image/tiff" || self == "image/webp" || self == "image/png"
        {
            return true;
        }
        return false;
    }
}


extension String {
    
    var length:Int { return  self.characters.count }
      
    func isEngWord() -> Bool {
        let engWords = "abcdefghijklmnopqrstuvwxyz"
        for var i = 0 ; i < self.length ;i = i + 1
        {
            let char = (self as NSString).substringWithRange(NSMakeRange(i, 1))
            if !engWords.containsString(char) && !engWords.uppercaseString.containsString(char) {
                return false
            }
        }
        
        return self.length > 0
    }
    
    func substringByRemoveUrlScheme() -> String
    {
        if self.hasPrefix("http:")
        {
            return self.substringFromIndex(self.startIndex.advancedBy(5))
        }
        else if self.hasPrefix("https:")
        {
            return self.substringFromIndex(self.startIndex.advancedBy(6))
        }
        return self
    }
    
    func getRootHost() -> String {
        var ar = self.componentsSeparatedByString(".")
        if ar.count >= 2 {
            if let newar = ar.subarrayWithRange(NSMakeRange(ar.count - 2, 2))
            {
                ar = newar
            }
        }
        return ar.joinWithSeparator(".")
    }

    func noHttpScheme() -> Bool {
        return !(self.hasPrefix("http://") || self.hasPrefix("https://"))
    }
    
    func stringByAppendingPathComponent(str:String) -> String {
        return (self as NSString).stringByAppendingPathComponent(str)
    }
    
    func TrimTryCatchCallBackWithPrefixSuffix(sPrefix:String,sSuffix:String) -> String{
        var sSub = ""
        let prefixRange = NSString(string: self).rangeOfString(sPrefix)
        if prefixRange.length > 0
        {
            let suffixRange = NSString(string: self).rangeOfString(sSuffix, options: NSStringCompareOptions.BackwardsSearch)
            if suffixRange.length > 0 && suffixRange.location >= prefixRange.location + prefixRange.length{
                sSub = NSString(string: self).substringWithRange(NSMakeRange(prefixRange.location + prefixRange.length, suffixRange.location - (prefixRange.location + prefixRange.length)))
            }
        }
        
        return sSub
    }
    
    func TrimTryCatchCallBackWithPrefixSuffix(sPrefixLength:Int,sSuffixLength:Int) -> String{
        var sSub = ""
        if sSuffixLength == 0{
            return self
        }
        
        let prefixRange = NSMakeRange(0, sPrefixLength)
        let suffixRange = NSMakeRange(self.length - sSuffixLength, sSuffixLength)
        if suffixRange.location >= prefixRange.location + prefixRange.length{
            sSub = NSString(string: self).substringWithRange(NSMakeRange(prefixRange.location + prefixRange.length, suffixRange.location - (prefixRange.location + prefixRange.length)))
        }
        
        return sSub
    }
    
    func getValidAnyObject(str:NSString) -> NSString{
        var sBack = NSString(string: "")
        let endRange = str.rangeOfString(")", options: NSStringCompareOptions.BackwardsSearch)
        if endRange.length > 0{
            let endLocation = endRange.location
            
            let tempStr:NSString = str.substringWithRange(NSMakeRange(0 , endLocation))
            
            if let utf8String = tempStr.dataUsingEncoding(NSUTF8StringEncoding),  _ = NSJSONSerialization.WQJSONObjectWithData(utf8String, options: NSJSONReadingOptions.MutableContainers, error: nil)
            {
                sBack = tempStr
            }
            else{
                sBack = self.getValidAnyObject(tempStr)
            }
        }
        
        return sBack
    }
    
    func filterNumber() -> String{
        let abcdednumber = self.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        return (abcdednumber as NSArray).componentsJoinedByString("")
    }
    
    func filterLetter() -> String{
        let abcdednumber = self.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet)
        return (abcdednumber as NSArray).componentsJoinedByString("")
    }
    
    func getBeforeDecimalPointValue() -> Float{
        let ar = self.componentsSeparatedByString(".")
        if ar.count > 0
        {
            let abcdednumber = ar[0].componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            return ((abcdednumber as NSArray).componentsJoinedByString("") as NSString).floatValue
        }
        return 0
    }
    
    func filterNumberLetter() -> String{
        let engWords = "abcdefghijklmnopqrstuvwxyz1234567890"
        var sFilter = ""
        for var i = 0 ; i < self.length ;i = i + 1
        {
            let char = (self as NSString).substringWithRange(NSMakeRange(i, 1))
            if engWords.containsString(char) || engWords.uppercaseString.containsString(char) {
                sFilter += char
            }
        }
        return sFilter
    }
    
    func filterNumberLetterAndPoint() -> String{
        let engWords = "abcdefghijklmnopqrstuvwxyz1234567890."
        var sFilter = ""
        for var i = 0 ; i < self.length ;i = i + 1
        {
            let char = (self as NSString).substringWithRange(NSMakeRange(i, 1))
            if engWords.containsString(char) || engWords.uppercaseString.containsString(char) {
                sFilter += char
            }
        }
        return sFilter
    }
    
    func trimSpaceNewLine() -> String {
        var s = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        s = s.stringByReplacingOccurrencesOfString(" ", withString: "")
        s = s.stringByReplacingOccurrencesOfString("\r\n", withString: "")
        s = s.stringByReplacingOccurrencesOfString("\n", withString: "")
        s = s.stringByReplacingOccurrencesOfString("\t", withString: "")
        return s
    }
    
    static func JSONPConvertToJSON(data:NSData) -> NSData? {
        
        return self.JSONPConvertToJsonWithRegularExpression(data, preRegularExpression: "^\\w*\\s*\\{?\\s*\\w*\\s*\\(", suffixRegularExpression: "\\);?$|\\);?\\s*\\}$|\\)\\s*;?\\}\\s*\\w+\\s*\\(\\w*\\)\\s*\\{?[^£]*\\}?$")
    }
    
    static func JSONPConvertToJsonWithRegularExpression(data:NSData,preRegularExpression preRegular:String,suffixRegularExpression suffixRegular:String,unicode:Bool = true) -> NSData? {
        var str = NSString(data: data, encoding: NSUTF8StringEncoding)
        if str == nil{
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            str = NSString(data: data, encoding: enc)
        }
        
        if str != nil{
            str = str!.stringByRemovingNewLinesAndWhitespace()
            
            if str == nil{
                return nil
            }
            
            return (str as! String).regularExpression(preRegular, suffixRegular: suffixRegular, unicode: unicode)
            
//            if let preRegex = try? NSRegularExpression(pattern: preRegular, options: NSRegularExpressionOptions.CaseInsensitive)
//            {
//                str = preRegex.stringByReplacingMatchesInString(str! as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, str!.length), withTemplate: "")
//                if let sufRegex = try? NSRegularExpression(pattern: suffixRegular, options: NSRegularExpressionOptions.CaseInsensitive)
//                {
//                    str = sufRegex.stringByReplacingMatchesInString(str! as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, str!.length), withTemplate: "")
//                    var tempRS:String = str as! String
//                    if unicode {
//                        tempRS = tempRS.stringByReplacingOccurrencesOfString("\\x", withString: "\\u00")
//                    }
//                    result = tempRS.dataUsingEncoding(NSUTF8StringEncoding)
//                    return result
//                }
//            }
        }
        return nil
    }
    
    func JSONPConvertToJsonWithRegularExpression(preRegular:String, suffixRegular:String, unicode:Bool = true) -> NSData? {
        let str = self.stringByRemovingNewLinesAndWhitespace()
        if str == nil{
            return nil
        }
        
        return str.regularExpression(preRegular, suffixRegular: suffixRegular,unicode: unicode)
    }
    
    func isHostFormat() -> Bool {
        let newstring = self.trimSpaceNewLine()
        let ar = newstring.componentsSeparatedByString(".")
        
        var isHost = false;
        if ar.count >= 2 {
            for item in ar
            {
                if item.filterLetter().length > 0 {
                    isHost = true
                    break
                }
            }
        }
        else{
            isHost = false;
        }
        
        return isHost
    }
    
    func parseText() -> [HostModel] {
        var models = [HostModel]()
        let text = self as NSString
        var ar = [String]()
        var seperators = ["\r\n","\r","\n"]
        var index = 0
        while ar.count <= 1 && index < seperators.count
        {
            ar = text.componentsSeparatedByString(seperators[index++])
        }
        
        for item in ar
        {
            var components = [String]()
            seperators = [" ","\t"]
            var index = 0;
            
            while components.count <= 1 && index < seperators.count
            {
                components = item.componentsSeparatedByString(seperators[index++])
                let model = HostModel()
                if components.count >= 2 {
                    for part in components {
                        if part.isHostFormat() {
                            model.name = part.trimSpaceNewLine()
                        }
                        else if part.isIPV4Format() {
                            model.value = part.trimSpaceNewLine()
                        }
                        model.envName = "测试环境"
                    }
                }
                if model.name.length > 0 && model.value.length > 0 {
                    models.append(model)
                }
            }
        }
        
        return models;
    }
    
    func isIPV4Format() -> Bool {
        let newstring = self.trimSpaceNewLine()
        let ar = newstring.componentsSeparatedByString(".")
        
        var isIP = true;
        if ar.count == 4 {
            for item in ar
            {
                if Int(item) == nil || Int(item) > 255 {
                    isIP = false
                    break
                }
            }
        }
        else{
            isIP = false;
        }
        
        return isIP
    }
    
    func onGetSubString(sBegin:String,sEnd:String,isInt:Bool) -> String
    {
        let beginRange = NSString(string: self).rangeOfString(sBegin)
        var beginLocation = -1
        var sBack = ""
        
        if beginRange.length > 0{
            beginLocation = beginRange.location + sBegin.length
            var suburl = NSString(string: self).substringFromIndex(beginLocation)
            suburl = (suburl as NSString).stringByReplacingOccurrencesOfString(".html", withString: "")
            let endRange = NSString(string: suburl).rangeOfString(sEnd)
            if endRange.length > 0{
                let endLocation = endRange.location + beginLocation
                
                if endLocation - beginLocation > 0{
                    sBack = NSString(string: self).substringWithRange(NSMakeRange(beginLocation, endLocation - beginLocation))
                }
            }
                //有可能只有sBegin的情况，而没有sEnd的情况
            else {
                if isInt {
                    if Int(suburl) >= 0{
                        sBack = suburl
                    }
                }
                else{
                    sBack = suburl
                }
            }
        }
        
        return sBack;
    }
    
    private func regularExpression(preRegular:String, suffixRegular:String,unicode:Bool = true) -> NSData?{
        var result:NSData? = nil
        if let preRegex = try? NSRegularExpression(pattern: preRegular, options: NSRegularExpressionOptions.CaseInsensitive)
        {
            var str = preRegex.stringByReplacingMatchesInString(self, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, self.length), withTemplate: "")
            if let sufRegex = try? NSRegularExpression(pattern: suffixRegular, options: NSRegularExpressionOptions.CaseInsensitive)
            {
                str = sufRegex.stringByReplacingMatchesInString(str, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, str.length), withTemplate: "")
                var tempRS:String = str
                if unicode {
                    tempRS = tempRS.stringByReplacingOccurrencesOfString("\\x", withString: "\\u00")
                }
                result = tempRS.dataUsingEncoding(NSUTF8StringEncoding)
            }
        }
        return result
    }
    
    func versionBiggerOrEqualThan(str:String) -> Bool
    {
        if str == self
        {
            return true
        }
        
        let re = self.compare(str, options: NSStringCompareOptions.NumericSearch, range: nil, locale:  nil)
        if re == NSComparisonResult.OrderedDescending || re == NSComparisonResult.OrderedSame
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func versionLessOrEqualthan(str:String) -> Bool
    {
        if str == self
        {
            return true
        }
        
        let re = self.compare(str, options: NSStringCompareOptions.NumericSearch, range: nil, locale:  nil)
        if re == NSComparisonResult.OrderedAscending || re == NSComparisonResult.OrderedSame
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func versionBiggerthan(str:String) -> Bool
    {
        if str == self
        {
            return false
        }

        let re = self.compare(str, options: NSStringCompareOptions.NumericSearch, range: nil, locale:  nil)
        if re == NSComparisonResult.OrderedDescending
        {
           return true
        }
        else
        {
           return false
        }
    }
    
 
    func jfsImageString() -> String
    {
        var path = self
        if let r = path.rangeOfString("jfs/") where r.startIndex < path.endIndex
        {
            path = path.substringFromIndex(r.startIndex)
        }
        return path
    }
    

    func getSpecialCharacterEncodeString(sescape:String = "") -> String{
        if let mutableCharaterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as? NSMutableCharacterSet
        {
            //对sescape进行编码
            mutableCharaterSet.removeCharactersInString(sescape)
            if let key = self.stringByAddingPercentEncodingWithAllowedCharacters(mutableCharaterSet)
            {
                return key
            }
        }
        
        return self
    }
 
    func filterSpace(seperate:String,maxLength:Int = 0) -> Array<String>{
        var ar = self.componentsSeparatedByString(seperate)
        if maxLength > 0 && ar.count > maxLength{
            if let obj = ar.subarrayWithRange(NSMakeRange(0, maxLength))
            {
                ar = obj
            }
        }
        
        ar = ar.filter({ (item) -> Bool in
            return item.length > 0
        })
        return ar
    }
    
 
    func imageRetrievalWithWidth(width:Int,height:Int,preItem:String) -> String {
        var urlString : String = ""
        
        var sizeStr = ""
        let hWidth:Int = Int(CGFloat(width) * 2)
        let hHeight:Int = Int(CGFloat(height) * 2)
        if width == 0 && height == 0 {
            sizeStr = "jfs/"
        }
        else {
            sizeStr = "s" + "\(hWidth)" + "x" + "\(hHeight)" + "_jfs/"
        }
        
        if self.hasPrefix("http:")
        {
            /////dfsd_jsf/
            if let preRegex = try? NSRegularExpression(pattern: "\\w*jfs/", options: NSRegularExpressionOptions.CaseInsensitive)
            {
                return preRegex.stringByReplacingMatchesInString(self, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, self.length), withTemplate:sizeStr)
                
            }
            
        }
        else{
            if let preRegex = try? NSRegularExpression(pattern: ".*jfs/", options: NSRegularExpressionOptions.CaseInsensitive)
            {
                let str = preRegex.stringByReplacingMatchesInString(self, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, self.length), withTemplate:sizeStr)
                urlString =  "http://img10.360buyimg.com/\(preItem)/\(str)"
            }
        }

        return urlString
    }
    
    mutating func imagePathWithRegular(width:Int,height:Int) {
        var sizeStr = ""
        let hWidth:Int = width * 2
        let hHeight:Int = height * 2
        if width == 0 && height == 0 {
            sizeStr = "/jfs/"
        }
        else {
            sizeStr = "/s" + "\(hWidth)" + "x" + "\(hHeight)" + "_jfs/"
        }
        
        /////dfsd_jsf/
        if let preRegex = try? NSRegularExpression(pattern: "/\\w*jfs/", options: NSRegularExpressionOptions.CaseInsensitive)
        {
            self = preRegex.stringByReplacingMatchesInString(self, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, self.length), withTemplate:sizeStr)
        }
    }

    
    func stringConvertToHex() -> UInt {
        
        return (self as NSString).convertToHex()
        
    }
    
    func getHashValueOfString() -> String{
        var hashValue = ""
        if self == "" {
            hashValue = ""
        }
        else {
            var hash:Int64 = 5381
            let scalars = self.unicodeScalars
            var startIndex = scalars.startIndex
            let length = scalars.count
            for i in 0 ..< length
            {
                var z = hash<<5
                z = z & 0x00000000ffffffff
                let z2 = scalars[startIndex].value
                let z3 = z + Int(z2)
                hash += z3
                startIndex = startIndex.advancedBy(1)
            }
            hashValue = "\((hash & 0x7fffffff))";

        }
        
        return hashValue

    }
    
}