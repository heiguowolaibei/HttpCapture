////  HttpCaptureManager.h()
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/14.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//


import Foundation

@objc class CallBackModel: NSObject
{
    var url = ""
    var callBack = ""
}

@objc class PageMessage: NSObject
{
    var pageID = ""
    var pageDate:NSDate?
}

enum UAPlatform : Int {
    case keepSameUA = 0,
    WeixinUA = 1,
    QQUA = 2
}

@objc class HttpCaptureManager: NSObject
{
    var items = NSMutableDictionary()
    var hostEntries = NSMutableDictionary()
    var hostIps = [String:String]()
    var logIndex:Int32 = 0
    let maxEntries = 1000
    static var monitoryQueue:dispatch_queue_t = dispatch_queue_create("jd_monitor", DISPATCH_QUEUE_SERIAL);
    let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
    var histories = Array<RecordModel>()
    var cachePath = FileHelper.CacheRootPath.stringByAppendingString("/monitor")
    var zipPath = FileHelper.CacheRootPath.stringByAppendingString("/monitorZips")
    var hostPath = FileHelper.CacheRootPath.stringByAppendingString("/host")
    var uplaodedPath = ""
    var uploadedPaths = NSMutableArray()
    var maxExistTime:NSTimeInterval = 3600 * 24 * 7
    private var uploadUrlProgressCallback = [CallBackModel]()
    var progressView:UIProgressView?
    var platform = UAPlatform.keepSameUA
        {
        didSet{
            WXSQHttpCookieManager.appendUserAgentToWeb()
        }
    }
    var totalEntries = [Entry]()
    var pageMsgs = [PageMessage]()
    var pageIndex = 0;
    @objc var currentUrl = AppConfiguration.Urls.guideUrl
    
    @objc func getPlatformID() -> Int {
        return self.platform.rawValue
    }
    
    @objc func appendPageMsg(date:NSDate){
        let info = PageMessage()
        info.pageDate = date
        info.pageID = DateFormatterManager.sharedInstance.parseStyleSync(0, date: date)
        self.pageMsgs.append(info)
    }
    
    @objc func appendHistoryMsg(url:String,date:NSDate){
        let his = RecordModel()
        his.url = url
        his.date = NSDate()
        self.histories.append(his)
    }
    
    @objc func getPageID(date:NSDate) -> String {
        for item in self.pageMsgs {
            if let itemDate = item.pageDate where date.timeIntervalSinceDate(itemDate) >= 0
            {
                return item.pageID
            }
        }
        
        return ""
    }
    
    func appendRequestEntry(entry:Entry) {
        dispatch_async(HttpCaptureManager.monitoryQueue) {
            if entry.request.bodySize > 500 * 1024
            {
                entry.request.postData.text = "上传内容过大，暂不允许显示"
            }
            if let log = self.items.objectForKey(NSNumber(int: self.logIndex)) as? HttpLog where log.entries.count >= self.maxEntries
            {
                self.saveHAR()
                self.logIndex += 1
            }
            
            if self.items.objectForKey(NSNumber(int: self.logIndex)) == nil
            {
                let log: HttpLog = HttpLog()
                log.browser.name = "UIWebView"
                log.browser.version = "1.0"
                log.creator.name = "BrowserMob Protocol"
                log.version = UIDevice.currentDevice().shortVersion()
                
                self.items.setObject(log, forKey: NSNumber(int: self.logIndex))
            }
            
            if let log = self.items.objectForKey(NSNumber(int:self.logIndex)) as? HttpLog where !log.existPage(entry.pageref)
            {
                let p: Page = Page()
                if let date = entry.getStartDate()
                {
                    DateFormatterManager.sharedInstance.parseStyle(6, date: date, block: { (s) in
                        p.startedDateTime = s
                    })
                    p.id = entry.pageref
                    p.title = entry.pageref
                }
                log.pages.append(p);
                log.appendPageID(entry.pageref)
            }
            
            if let log = self.items.objectForKey(NSNumber(int: self.logIndex)) as? HttpLog
            {
                log.entries.append(entry)
            }
            self.totalEntries.append(entry)
        }
    }
    
    //只允许当前相同的一个url的上传接口存在
    func updateUploadUrlProgressCallback(key:String,value:String)  {
        if self.queryModelForKey(key) != nil {
            return
        }
        let model = CallBackModel()
        model.url = key
        model.callBack = value
        
        uploadUrlProgressCallback.append(model)
    }
    
    func removeEntries(arr:NSArray,block:(rs:Bool) -> Void) {
        dispatch_async(HttpCaptureManager.monitoryQueue) {
            let ar = NSMutableArray(array: self.totalEntries)
            ar.removeObjectsInArray(arr as [AnyObject])
            if let newar = ar as? [Entry]
            {
                self.totalEntries = newar
            }
            dispatch_async(dispatch_get_main_queue()) {
                block(rs:true)
            }
        }
    }
    
    func queryModelForKey(key:String) -> CallBackModel? {
        for item in uploadUrlProgressCallback
        {
            if item.url == key
            {
                return item
            }
        }
        return nil;
    }
    
    func removeUploadUrlProgressCallback(key:String){
        var indexs = [Int]()
        for (index,item) in uploadUrlProgressCallback.enumerate()
        {
            if item.url == key
            {
                indexs.append(index)
            }
        }
        for index in indexs
        {
            uploadUrlProgressCallback.removeAtIndex(index)
        }
    }
    
    func getUploadUrlProgressCallback() -> [CallBackModel] {
        return uploadUrlProgressCallback
    }
    
    func uploadZip(code:String,key:String,filepaths:[String]? = nil,block:(rs:Bool) -> Void)
    {
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
        progressView?.frame = CGRectMake(0, 0, WXDevice.width/2, 30)
        
        if let pro = progressView
        {
            let centerView = UIView(frame:CGRectMake(0,0,WXDevice.width/2,60))
            centerView.backgroundColor = UIColor.clearColor()
            centerView.addSubview(pro)
            pro.center = centerView.center
            MBProgressHUDHelper.sharedMBProgressHUDHelper.showLoadingWithCusView(centerView, superView: nil, bUserInteractionEnabed: true)
        }
        
        var zippath = ""
        var harpaths = [String]()
        if let paths = filepaths
        {
            zippath = HttpCaptureManager.shareInstance().zipHarsWithPaths(paths)
            harpaths = paths
        }
        else
        {
            let group = HttpCaptureManager.shareInstance().zipHars()
            zippath = group.0
            harpaths = group.1
        }
        
        let af = AFHTTPSessionManager()
        
        var url = "http://wq.jd.com/webreport/harupload?code=\(code)&key=\(key)&os=iOS&module=\(UIDevice.currentDevice().platformString())";
        url = url.trimSpaceNewLine()
        let request:NSMutableURLRequest = af.requestSerializer.multipartFormRequestWithMethod("POST", URLString: url, parameters: nil, constructingBodyWithBlock: {(data:AFMultipartFormData!) -> Void in
                
//                let abd = FileHelper.CacheRootPath.stringByAppendingString("/monitorZips/1472192579.3674.zip");
                try? data.appendPartWithFileURL(NSURL(fileURLWithPath:zippath), name: "upload")
            
        },error:nil)
        
        var progress:NSProgress?
        let uploadTask = af.uploadTaskWithStreamedRequest(request, progress: &progress) { (response, responseObject, error) -> Void in
            
            var isok = false;
            var errcode = 0
            
            if error == nil {
                if let errid = (responseObject as? Dictionary<String,AnyObject>)?["errId"] as? Int where errid == 0
                {
                    errcode = errid;
                    for path in harpaths
                    {
                        FileHelper.FileManager.WQremoveItemAtPath(path, error: nil)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(AppConfiguration.NotifyNames.refreshFileNotification, object: nil)
                    MBProgressHUDHelper.sharedMBProgressHUDHelper.hidden(nil, animation: true)
                    FileHelper.FileManager.WQremoveItemAtPath(zippath, error: nil)
                    isok = true
                }
            }
            
            if (!isok){
                MBProgressHUDHelper.sharedMBProgressHUDHelper.hidden(nil, animation: false)
                var msg = "errcode=\(errcode)"
                if let res = responseObject as? Dictionary<String,AnyObject>
                {
                    msg += res.description
                }
                if let err = error
                {
                    msg += err.description
                }
                let alert = UIAlertView(title: "", message: msg, delegate: nil, cancelButtonTitle: "好的")
                alert.show()
            }
            
            block(rs:error == nil)
            
            self.removeUploadUrlProgressCallback(url)
        }
        
        self.updateUploadUrlProgressCallback(url, value: "updateProgress:bytesSent:totalBytesSent:totalBytesExpectedToSend:")
        uploadTask.resume()
    }
    
    func updateProgress(url:String,bytesSent:String,totalBytesSent:String,totalBytesExpectedToSend:String)  {
        dispatch_async(dispatch_get_main_queue()) {
            DPrintln("asdfasd =\(url);\(bytesSent);\(totalBytesSent);\(totalBytesExpectedToSend)");
            if let _totalBytes = Float(totalBytesSent) , let _totalBytesExpected = Float(totalBytesExpectedToSend)
            {
                self.progressView?.setProgress( _totalBytes / _totalBytesExpected, animated: true)
            }
        }
    }
    
    func zipHarsWithPaths(filePaths:[String]) -> String {
        let zippath = HttpCaptureManager.shareInstance().zipPath.stringByAppendingString("/iOS_\(NSDate().timeIntervalSince1970).zip")
        SSZipArchive.createZipFileAtPath(zippath, withFilesAtPaths: filePaths)
        
        return zippath
    }
    
    func zipHars() -> (String,[String]) {
        let contentCachePach = HttpCaptureManager.shareInstance().cachePath
        let zippath = HttpCaptureManager.shareInstance().zipPath.stringByAppendingString("/iOS_\(NSDate().timeIntervalSince1970).zip")
        let fileManager = NSFileManager.defaultManager()
        var error : NSError?
        var filePaths = [String]()
        let dic = fileManager.WQcontentsOfDirectoryAtPath(contentCachePach, error: &error)
        let maxsize = 20;
        if let files = dic
        {
            for (index,fileName) in files.enumerate(){
                if index < maxsize
                {
                    let filePath = contentCachePach.stringByAppendingPathComponent(fileName)
                    filePaths.append(filePath)
                }
            }
            SSZipArchive.createZipFileAtPath(zippath, withFilesAtPaths: filePaths)
        }
        
        return (zippath,filePaths)
    }
    
    func saveHAR() {
        dispatch_async(HttpCaptureManager.monitoryQueue) {
            for (key,value) in self.items
            {
                let path = FileHelper.CacheRootPath.stringByAppendingString("/monitor/\(NSDate().timeIntervalSince1970).har");
                let dic = NSMutableDictionary()
                let json = value.serializeToJsonObject()
                dic.setObject(json, forKey: "log")
                
                DPrintln("pppp path = \(path)")
                if let en = value as? HttpLog
                {
                    DPrintln("entries.count = \(en.entries.count)")
                }

                if let data = NSJSONSerialization.WQdataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                {
                    let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    try? jsonString?.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
                    self.items.removeObjectForKey(key)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(AppConfiguration.NotifyNames.refreshFileNotification, object: nil)
            })
        }
    }
    
    func getAllEntries(block:(re:NSMutableArray)->Void) {
        dispatch_async(HttpCaptureManager.monitoryQueue) {
            let ar = NSMutableArray(array: self.totalEntries)
            dispatch_async(dispatch_get_main_queue(), {
                block(re:ar);
            })
        }
    }
    
    func appendHostIp(models:[HostModel])
    {
        dispatch_sync(lockQueue) {
            self.hostIps.removeAll()
            for model in models{
                if model.enable {
                    self.hostIps[model.name] = model.value
                }
            }
        }
        
    }
    
    func hostedRequestWithRequest(originRequest:NSURLRequest) -> NSURLRequest
    {
        dispatch_sync(lockQueue) {
            
        }
        if let url = originRequest.URL?.absoluteString ,let host = originRequest.URL?.host?.lowercaseString,let ip = self.hostIps[host]
        {
            let replaceURLString = (url as NSString).stringByReplacingOccurrencesOfString(host, withString: ip)
            if let url = NSURL(string:replaceURLString)
            {
                let mutableReqeust = NSMutableURLRequest(URL: url, cachePolicy: originRequest.cachePolicy, timeoutInterval: originRequest.timeoutInterval);
                mutableReqeust.allHTTPHeaderFields = originRequest.allHTTPHeaderFields;
                if let method = originRequest.HTTPMethod
                {
                    mutableReqeust.HTTPMethod = method;
                }
                mutableReqeust.HTTPBody = originRequest.HTTPBody;
                mutableReqeust.HTTPBodyStream = originRequest.HTTPBodyStream;
                mutableReqeust.HTTPShouldHandleCookies = originRequest.HTTPShouldHandleCookies;
                mutableReqeust.HTTPShouldUsePipelining = originRequest.HTTPShouldUsePipelining;
                if let key = NSURLProtocol.propertyForKey("OCDHTTPWatcher", inRequest: originRequest)
                {
                    NSURLProtocol.setProperty(key, forKey: "OCDHTTPWatcher", inRequest: mutableReqeust)
                }
                
                return mutableReqeust
            }
        }
        
        return originRequest;
    }
    
    static var onceToken : dispatch_once_t = 0
    static var ins: HttpCaptureManager? = nil
    class func shareInstance() -> HttpCaptureManager {
        dispatch_once(&onceToken, {() -> Void in
            ins = HttpCaptureManager()
        })
        return ins!
    }
    
    override init()
    {
        super.init()
        FileHelper.createDirectoryNotExistWithPath(self.cachePath)
        FileHelper.createDirectoryNotExistWithPath(self.zipPath)
        FileHelper.createDirectoryNotExistWithPath(self.hostPath)
        
        uplaodedPath = FileHelper.CacheRootPath.stringByAppendingString("uploadedHar.plist")
        
        if FileHelper.FileManager.fileExistsAtPath(uplaodedPath)
        {
            if let ar = NSMutableArray(contentsOfFile: uplaodedPath)
            {
                uploadedPaths = ar
            }
        }
        
        let path = hostPath.stringByAppendingString("/host")
        
        if let obj = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Dictionary<String,Array<HostModel>>
        {
            var models = Array<HostModel>()
            for (_,value) in obj
            {
                models.appendContentsOf(value)
            }
            self.appendHostIp(models)
        }
    }

    func removeExpireHar(contentCachePach:String){
        let fileManager = NSFileManager.defaultManager()
        var toRemovePaths = [String]()
        var error : NSError?
        let dic = fileManager.WQcontentsOfDirectoryAtPath(contentCachePach, error: &error)
        if let files = dic
        {
            for fileName in files{
                let filePath = contentCachePach.stringByAppendingPathComponent(fileName)
                var properties = fileManager.WQattributesOfItemAtPath(filePath, error: &error)
                if properties != nil
                {
                    let obj: AnyObject? = properties![NSFileModificationDate]
                    
                    if let mdate = obj as? NSDate
                    {
                        if NSDate().timeIntervalSinceDate(mdate) >= maxExistTime
                        {
                            toRemovePaths.append(filePath)
                        }
                    }
                }
            }
        }
        
        for path in toRemovePaths
        {
            FileHelper.FileManager.WQremoveItemAtPath(path, error: nil)
        }
        if toRemovePaths.count > 0 {
            NSNotificationCenter.defaultCenter().postNotificationName(AppConfiguration.NotifyNames.refreshFileNotification, object: nil)
        }
    }
}

















