//
//  HttpSummary.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/15.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit
import Foundation

class HttpSummaryHelper:NSObject
{
    
}

@objc class HttpLog: NSObject {
    var browser = Browser()
    var comment = ""
    var creator = Creator()
    var entries = [Entry]()
    var pages = Array<Page>()
    var version = ""
    
    private var url = ""
    private var bSaved = false
    private var pageIDs = [String]()
    
    func setLoadURL(_url:String)  {
        url = _url;
    }
    
    func getUrl() -> String {
        return url;
    }
    
    func setSaved(saved:Bool) {
        self.bSaved = saved;
    }
    
    func saved() -> Bool {
        return self.bSaved
    }
    
    func appendPageID(sid:String) {
        self.pageIDs.append(sid)
    }
    
    func getPageIDs() -> [String]{
        return self.pageIDs
    }
    
    func existPage(page:String) -> Bool {
        return self.pageIDs.contains(page);
    }
}

//"creator": {
//    "name": "Firebug",
//    "version": "1.6",
//    "comment": "",
//}
//
class Creator: NSObject {
    var name = ""
    var version = ""
    var comment = ""
    
    
}

//"browser": {
//    "name": "Firefox",
//    "version": "3.6",
//    "comment": ""
//}
class Browser: NSObject {
    var name = ""
    var version = ""
    var comment = ""
    
    
}

//"pages": [
//{
//"startedDateTime": "2009-04-16T12:07:25.123+01:00",
//"id": "page_0",
//"title": "Test Page",
//"pageTimings": {...},
//"comment": ""
//}
//]
class Page:NSObject{
    var startedDateTime = ""
    var id = ""
    var title = ""
    var pageTimings = [PageTiming]()
    var comment = ""

}

//"onContentLoad": 1720,
//"onLoad": 2500,
//"comment": ""
class PageTiming:NSObject
{
    var onContentLoad:Int64 = 0     //页面内容加载的时间
    var onLoad:Double = 0
    var comment  = ""
    
    private var startTime:NSDate?
    
    func setStartTime(date:NSDate){
        self.startTime = date
    }
    
    func setOnLoadTime(endDate:NSDate)
    {
        if let time = self.startTime
        {
            onLoad = endDate.timeIntervalSinceDate(time)
        }
    }
}

//"pageref": "page_0",
//"startedDateTime": "2009-04-16T12:07:23.596Z",
//"time": 50,
//"request": {...},
//"response": {...},
//"cache": {...},
//"timings": {},
//"serverIPAddress": "10.0.0.1",
//"connection": "52492",
//"comment": ""
class Entry:NSObject
{
    var pageref = ""
    var startedDateTime = ""
    var time:Double = 0
    var request = Request()
    var response = Response()
    var cache = Cache()
    var timings = Timings()
    var serverIPAddress = ""
    var connection = ""
    var comment = ""
    private var startDate:NSDate?
    private var startTime:String?
    private var URL:NSURL?
    
    func setURL(url:NSURL?)  {
        self.URL = url
    }
    
    func getURL() -> NSURL? {
        return self.URL;
    }
    
    func setEntryStartedDateTime(date:NSDate)
    {
        weak var wself = self
        self.startDate = date;
        DateFormatterManager.sharedInstance.parseStyle(6, date: date) { (s) in
            wself?.startedDateTime = s
        }
        DateFormatterManager.sharedInstance.parseStyle(0, date: date) { (s) in
            wself?.startTime = s
        }
    }
    
    func getStartTime() -> String {
        if let t = self.startTime
        {
            return t;
        }
        return "";
    }
    
    func setEntryTime(enddate:NSDate)
    {
        if let t = self.startDate
        {
            self.time = enddate.timeIntervalSinceDate(t)
        }
    }
    
    func getStartDate() -> NSDate? {
        return self.startDate;
    }
    
    func configEntry(pageref:String,startedDateTime:String,time:Double,request:Request,response:Response,cache:Cache,timings:Timings,serverIPAddress:String,connection:String,comment:String)
    {
        self.pageref = pageref;
        self.startedDateTime = startedDateTime;
        self.time = time;
        self.request = request;
        self.response = response;
        self.cache = cache;
        self.timings = timings;
        self.serverIPAddress = serverIPAddress;
        self.connection = connection;
        self.comment = comment;
    }
}

//"request": {
//    "method": "GET",
//    "url": "http://www.example.com/path/?param=value",
//    "httpVersion": "HTTP/1.1",
//    "cookies": [],
//    "headers": [],
//    "queryString" : [],
//    "postData" : {},
//    "headersSize" : 150,
//    "bodySize" : 0,
//    "comment" : "",
//}
class Request: NSObject {
    var method = ""
    var url = ""
    var httpVersion = "HTTP/1.1"
    var cookies = [Cookie]()
    var headers = [Header]()
    var queryString = [QueryStringParam]()
    var postData = PostData()
    var headersSize:Int64 = 0
    var bodySize:Int64 = 0
    var comment = ""
    private var reID = ""
    
    convenience init(re:NSURLRequest,cookies:[NSHTTPCookie],postData:PostData,headersSize:Int64,bodySize:Int64,comment:String,reID:String)
    {
        self.init()
        if let me = re.HTTPMethod
        {
            self.method = me
        }
        if let url = re.URL?.absoluteString
        {
            self.url = url;
        }
        for co in cookies {
            self.cookies.append(Cookie(cookie: co));
        }
        if let fields = re.allHTTPHeaderFields
        {
            for (key,value) in fields
            {
                if key == "HTTPBody" || key == "parameters" {
                    continue
                }
                headers.append(Header(name: key,value: value))
            }
        }
        if let sQuery = re.URL?.query
        {
            let querys = sQuery.componentsSeparatedByString("&")
            for query in querys {
                let namevalue = query.componentsSeparatedByString("=")
                if namevalue.count == 2
                {
                    queryString.append(QueryStringParam(name: namevalue[0],value:namevalue[1]))
                }
            }
        }
        self.postData = postData;
        self.headersSize = headersSize;
        self.bodySize = bodySize;
        self.comment = comment;
        
        self.reID = reID;
    }
    
    func getRequestID() -> String {
        return reID;
    }
}


//"response": {
//    "status": 200,
//    "statusText": "OK",
//    "httpVersion": "HTTP/1.1",
//    "cookies": [],
//    "headers": [],
//    "content": {},
//    "redirectURL": ",
//    "headersSize" : 160,
//    "bodySize" : 850,
//    "comment" : ""
//}
class Response: NSObject{
    var status:Int64 = 0
    var statusText = ""
    var httpVersion = ""
    var cookies = [Cookie]()
    var headers = [Header]()
    var content = Content()
    var redirectURL = ""
    var headersSize:Int64 = 0
    var bodySize:Int64 = 0
    var comment = ""
    
    
    convenience init(status:Int64,statusText:String,httpVersion:String,cookies:[NSHTTPCookie],headers:[String:String],content:Content,redirectURL:String,headersSize:Int64,bodySize:Int64,comment:String)
    {
        self.init()
        
        self.status = status;
        self.statusText = statusText;
        self.httpVersion = httpVersion;
        
        for cookie in cookies {
            self.cookies.append(Cookie(cookie: cookie))
        }
        
        for (key,value) in headers {
            self.headers.append(Header(name: key,value:value))
        }
        
        self.content = content;
        self.redirectURL = redirectURL;
        self.headersSize = headersSize;
        self.bodySize = bodySize;
        self.comment = comment;
    }
}

//"name": "TestCookie",
//"value": "Cookie Value",
//"path": "/",
//"domain": "www.janodvarko.cz",
//"expires": "2009-07-24T19:20:30.123+02:00",
//"httpOnly": false,
//"secure": false,
//"comment": "",
class Cookie: NSObject {
    var name = ""
    var value = ""
    var path = ""
    var domain = ""
    var expires = ""
    var httpOnly = false
    var secure = false
    var comment = ""
    
    convenience init(cookie:NSHTTPCookie){
        self.init()
        
        self.name = cookie.name
        self.value = cookie.value
        self.path = cookie.path
        self.domain = cookie.domain
        
        if let date = cookie.expiresDate
        {
            DateFormatterManager.sharedInstance.parseStyle(6, date: date, block: { (s) in
                self.expires = s
            })
        }
        self.httpOnly = cookie.HTTPOnly
        self.secure = cookie.secure
    }
}

//"name": "Accept-Encoding",
//"value": "gzip,deflate",
//"comment": ""
class Header:NSObject{
    var name = ""
    var value = ""
    var comment  = ""
    
    convenience init(name:String,value:String){
        self.init()
        
        self.name = name
        self.value = value
    }
}

class QueryStringParam: NSObject {
    var name = ""
    var value = ""
    var comment  = ""
    
    convenience init(name:String,value:String){
        self.init()
        
        self.name = name
        self.value = value
    }
}

//"mimeType": "multipart/form-data",
//"params": [],
//"text" : "plain posted data",
//"comment": ""
class PostData: NSObject {
    var mimeType = ""
    var params = [Param]()
    var text = ""
    var comment = ""
    
    convenience init(mimeType:String,parameters:Dictionary<String,AnyObject>,text:String,comment:String){
        self.init()
        
        self.mimeType = mimeType
        for (key,value) in parameters {
            if let s = value as? String
            {
                params.append(Param(name: key,value:s))
            }
            else{
                if let data = NSJSONSerialization.WQdataWithJSONObject(value, options: NSJSONWritingOptions.PrettyPrinted, error: nil),let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                {
                    params.append(Param(name: key,value:str as String))
                }
                else{
                    params.append(Param(name: key,value:"undefined"))
                }
            }
        }
        self.text = text
        self.comment = comment
    }
}

//"name": "paramName",
//"value": "paramValue",
//"fileName": "example.pdf",
//"contentType": "application/pdf",
//"comment": ""
class Param:NSObject{
    var name = ""
    var value = ""
    var fileName = ""
    var contentType = ""
    var comment = ""
    
    convenience init(name:String,value:String){
        self.init()
        
        self.name = name
        self.value = value
    }
}

//"content": {
//    "size": 33,
//    "compression": 0,
//    "mimeType": "text/html; charset="utf-8",
//    "text": "n",
//    "comment": ""
//}
class Content:NSObject{
    var size:Int64 = 0
    var compression:Int64 = 0
    var mimeType = ""
    var text = ""
    var encoding = ""           //如base64编码
    var comment = ""
    private var datapath = ""
    private var url = ""
    private var data = NSData()
        {
        didSet{
            self.write(url)
        }
    }
    static var ioQueue:dispatch_queue_t = dispatch_queue_create("jd_monitor", DISPATCH_QUEUE_SERIAL);
    
    convenience init(size:Int64,mimeType:String,text:String,encoding:String,comment:String,data:NSData,url:String){
        self.init()
        
        self.size = size
        self.mimeType = mimeType
        self.text = text
        self.encoding = encoding
        self.comment = comment
        
        self.url = url;
        self.data = data
    }
    
    func setData(data:NSData) {
        self.data = data;
    }
    
    func write(url:String)  {
        if data.length > 0 {
            FileHelper.createDirectoryNotExistWithPath(FileHelper.CacheRootPath.stringByAppendingString("/image"))
            let path = FileHelper.CacheRootPath.stringByAppendingString("/image/\((url as String).MD5())");
            datapath = path
            let newdata = NSMutableData(data: self.data)
            dispatch_async(Content.ioQueue) {
                newdata.writeToFile(path, atomically: true)
            }
        }
    }
    
    func getdatapath() -> String {
        return datapath;
    }
    
    func getImage(url:String,resultBlock:(img:UIImage?) -> Void) {
        dispatch_async(Content.ioQueue) {
            FileHelper.createDirectoryNotExistWithPath(FileHelper.CacheRootPath.stringByAppendingString("/image"))
            let path = FileHelper.CacheRootPath.stringByAppendingString("/image/\((url as String).MD5())");
            if let data = NSData(contentsOfFile: path)
            {
                let img = UIImage.sd_imageWithData(data)
                dispatch_async(dispatch_get_main_queue(), {
                    resultBlock(img: img)
                })
            }
        }
    }
    
    func imgIsExist(url:String) -> Bool {
        FileHelper.createDirectoryNotExistWithPath(FileHelper.CacheRootPath.stringByAppendingString("/image"))
        let path = FileHelper.CacheRootPath.stringByAppendingString("/image/\((url as String).MD5())");
        return FileHelper.FileManager.fileExistsAtPath(path)
    }
}

//"beforeRequest": {},
//"afterRequest": {},
//"comment": ""
class Cache:NSObject
{
    var beforeRequest = BeforeRequest()
    var afterRequest = AfterRequest()
    var comment = ""
}

//"expires": "2009-04-16T15:50:36",
//"lastAccess": "2009-16-02T15:50:34",
//"eTag": ",
//"hitCount": 0,
//"comment": "“”
class BeforeRequest:NSObject
{
    var expires = ""
    var lastAccess = ""
    var eTag = "0"
    var hitCount:Int64 = 0
    var comment = ""
    
    convenience init(expires:String,lastAccess:String,etag:String,hitAcount:Int64,comment:String){
        self.init()
        
        self.expires = expires
        self.lastAccess = lastAccess
        self.eTag = etag
        self.hitCount = hitAcount
        self.comment = comment
    }
}

class AfterRequest:NSObject
{
    var expires = ""
    var lastAccess = ""
    var eTag = "1"
    var hitCount:Int64 = 0
    var comment = ""
    
    convenience init(expires:String,lastAccess:String,etag:String,hitAcount:Int64,comment:String){
        self.init()
        
        self.expires = expires
        self.lastAccess = lastAccess
        self.eTag = etag
        self.hitCount = hitAcount
        self.comment = comment
    }
}

//"timings": {
//    "blocked": 0,
//    "dns": -1,
//    "connect": 15,
//    "send": 20,
//    "wait": 38,
//    "receive": 12,
//    "ssl": -1,
//    "comment": ""
//}
class Timings:NSObject{
    var blocked:Double = 0
    var dns:Double = 0
    var connect:Double = 0
    var send:Double = 0
    var wait:Double = 0
    var receive:Double = 0
    var ssl:Double = 0
    var comment = ""
    
    private var receiveResponseDate:NSDate?
    
    convenience init(blocked:Double,dns:Double,connect:Double,send:Double,wait:Double,receive:Double,ssl:Double,comment:String)
    {
        self.init()
        
        self.blocked = blocked
        self.dns = dns
        self.connect = connect
        self.send = send
        self.wait = wait
        self.receive = receive
        self.ssl = ssl;
        self.comment = comment
    }
    
    func setWaitTime(startDate:NSDate,endDate:NSDate) {
        self.wait = endDate.timeIntervalSinceDate(startDate)
        receiveResponseDate = endDate;
    }
    
    func setSendTime(startSendDate:NSDate,endSendDate:NSDate) {
        self.send = endSendDate.timeIntervalSinceDate(startSendDate)
    }
    
    func setReceiveTime(endDate:NSDate) {
        if let receiveResponse = self.receiveResponseDate {
            self.receive = endDate.timeIntervalSinceDate(receiveResponse)
        }
    }
}




















