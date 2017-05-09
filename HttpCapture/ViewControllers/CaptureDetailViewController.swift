//
//  CaptureDetailViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/24.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit
import Foundation

struct CaptureDetailKeys {
    static let overviewKey = "Overview"
    static let timingKey = "Timings"
    static let cookiesSentKey = "Cookies Send"
    static let cookiesReceiveKey = "Cookies Receive"
    static let postDataKey = "Request Post"
    static let contentKey = "Response Content"
    static let resquestHeadersKey = "Request Headers"
    static let responseHeadersKey = "Response Headers"
    
}

class CaptureDetailData:NSObject
{
    var name:String?
    var value:String?
    var needDetail = false;
}

class CaptureDetailViewController: CaptureBaseViewController
    ,UITableViewDelegate,UITableViewDataSource
{
    var entry = Entry()
    var tableView = UITableView()
    var datasource = NSMutableDictionary()
    var headerKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configData()
        self.configUI()
    }
    
    func configData()  {
        var overviewInfos = [CaptureDetailData]()
        
        var info = CaptureDetailData()
        info.name = "URL"
        info.value = self.entry.getURL()?.absoluteString
        info.needDetail = true
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Result Status Code"
        info.value = "\(self.entry.response.status)"
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "ID"
        info.value = "\(self.entry.request.getRequestID())"
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Method"
        info.value = "\(self.entry.request.method)"
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Start At"
        info.value = "\(self.entry.getStartTime())"
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Time"
        info.value = "\(self.entry.time)"
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Client IP"
        info.value = NSString.getIPAddress() as String
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Redirect URL"
        info.value = entry.response.redirectURL
        info.needDetail = true
        overviewInfos.append(info)

        datasource[CaptureDetailKeys.overviewKey] = overviewInfos
        headerKeys.append(CaptureDetailKeys.overviewKey)
        
        overviewInfos = [CaptureDetailData]()
        info = CaptureDetailData()
        info.name = "Send"
        info.value = "\(self.entry.timings.send)"
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Wait"
        info.value = "\(self.entry.timings.wait)"
        overviewInfos.append(info)
        
        info = CaptureDetailData()
        info.name = "Receive"
        info.value = "\(self.entry.timings.receive)"
        overviewInfos.append(info)
        datasource[CaptureDetailKeys.timingKey] = overviewInfos
        headerKeys.append(CaptureDetailKeys.timingKey)
        
        overviewInfos = [CaptureDetailData]()
        if entry.request.cookies.count>0
        {
            for cookie in entry.request.cookies
            {
                info = CaptureDetailData()
                info.name = cookie.name
                info.value = cookie.value
                info.needDetail = true
                overviewInfos.append(info)
            }
            datasource[CaptureDetailKeys.cookiesSentKey] = overviewInfos
            headerKeys.append(CaptureDetailKeys.cookiesSentKey)
        }
        overviewInfos = [CaptureDetailData]()
        if entry.response.cookies.count>0
        {
            for cookie in entry.response.cookies
            {
                info = CaptureDetailData()
                info.name = cookie.name
                info.value = cookie.value
                info.needDetail = true
                overviewInfos.append(info)
            }
            datasource[CaptureDetailKeys.cookiesReceiveKey] = overviewInfos
            headerKeys.append(CaptureDetailKeys.cookiesReceiveKey)
        }
        overviewInfos = [CaptureDetailData]()
        if entry.request.postData.text.length > 0 {
            for param in entry.request.postData.params
            {
                info = CaptureDetailData()
                info.name = param.name
                info.value = param.value
                info.needDetail = true
                overviewInfos.append(info)
            }
            info = CaptureDetailData()
            info.name = "Text"
            info.value = entry.request.postData.text
            info.needDetail = true
            overviewInfos.append(info)
            
            info = CaptureDetailData()
            info.name = "BodySize"
            info.value = "\(entry.request.bodySize)"
            overviewInfos.append(info)
            
            datasource[CaptureDetailKeys.postDataKey] = overviewInfos
            headerKeys.append(CaptureDetailKeys.postDataKey)
        }
        
        overviewInfos = [CaptureDetailData]()
        info = CaptureDetailData()
        info.name = "size"
        info.value = "\(entry.response.content.size)"
        overviewInfos.append(info)
        info = CaptureDetailData()
        info.name = "mimeType"
        info.value = "\(entry.response.content.mimeType)"
        overviewInfos.append(info)
        info = CaptureDetailData()
        info.name = "text"
        info.value = "\(entry.response.content.text)"
        info.needDetail = true
        overviewInfos.append(info)
        info = CaptureDetailData()
        info.name = "encoding"
        info.value = "\(entry.response.content.encoding)"
        overviewInfos.append(info)
        if entry.response.content.mimeType.judgeIsImage() && entry.response.content.imgIsExist(entry.request.url)
        {
            info = CaptureDetailData()
            info.name = "image"
            info.value = "点击查看图片"
            info.needDetail = true
            overviewInfos.append(info)
        }
        datasource[CaptureDetailKeys.contentKey] = overviewInfos
        headerKeys.append(CaptureDetailKeys.contentKey)
        
        overviewInfos = [CaptureDetailData]()
        for item in  entry.request.headers
        {
            info = CaptureDetailData()
            info.name = item.name
            info.value = item.value
            info.needDetail = true
            overviewInfos.append(info)
        }
        datasource[CaptureDetailKeys.resquestHeadersKey] = overviewInfos
        headerKeys.append(CaptureDetailKeys.resquestHeadersKey)
        
        overviewInfos = [CaptureDetailData]()
        for item in  entry.response.headers
        {
            info = CaptureDetailData()
            info.name = item.name
            info.value = item.value
            info.needDetail = true
            overviewInfos.append(info)
        }
        datasource[CaptureDetailKeys.responseHeadersKey] = overviewInfos
        headerKeys.append(CaptureDetailKeys.responseHeadersKey)
    }
    
    func configUI()  {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView(frame:CGRectZero)
        self.view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("CellID")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CellID")
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.None
        
        if headerKeys.count > indexPath.section
        {
            let key = headerKeys[indexPath.section]
            if let ar = datasource.objectForKey(key) as? Array<CaptureDetailData> where ar.count > indexPath.row
            {
                let data = ar[indexPath.row]
                cell?.textLabel?.text = data.name
                var s = data.value
                if data.value?.length > 30
                {
                    if let ss = data.value as? NSString
                    {
                        s = ss.substringToIndex(30)
                    }
                }
                cell?.detailTextLabel?.text = s
                cell?.accessoryType = data.needDetail ? UITableViewCellAccessoryType.DisclosureIndicator : UITableViewCellAccessoryType.None
            }
        }
        
        cell?.textLabel?.numberOfLines = 1;
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell?.detailTextLabel?.numberOfLines = 1;
        cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if headerKeys.count > section
        {
            let key = headerKeys[section]
            if let ar = datasource.objectForKey(key) as? Array<CaptureDetailData>
            {
                return ar.count
            }
        }

        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if cell?.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator
        {
            let textvc = SearchViewController(showSegment: true)
            var isImage = false
            
            if headerKeys.count > indexPath.section
            {
                if let key = headerKeys[indexPath.section] as? String
                {
                    if let ar = datasource[key] as? Array<CaptureDetailData>
                    {
                        if ar.count > indexPath.row
                        {
                            let data = ar[indexPath.row]
                            if data.name == "image" && key == CaptureDetailKeys.contentKey
                            {
                                entry.response.content.getImage(entry.request.url, resultBlock: { (img) in
                                    textvc.img = img
                                })
                                isImage = true
                            }
                            
                            if !isImage && data.value?.length > 0
                            {
                                let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC) / 10 * 3)
                                dispatch_after(popTime, dispatch_get_main_queue(), {
                                    textvc.text = data.value!
                                })
                            }
                            
                            if isImage || (!isImage && data.value?.length > 0)
                            {
                                textvc.entry = self.entry
                                self.navigationController?.pushViewController(textvc, animated: true)
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerKeys.count > section
        {
            if let key = headerKeys[section] as? String
            {
                let header = UIButton(frame:CGRectMake(0,0,self.view.width,30))
                header.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                header.setTitle("    \(key)", forState: UIControlState.Normal)
                header.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                header.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
                header.titleLabel?.numberOfLines = 1
                return header
            }
        }
        
        return nil;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return headerKeys.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        self.onSetMarginOrInset(true, fSetOffset: 10, cell: cell)
    }
    
    func onSetMarginOrInset(bSetTable:Bool,fSetOffset:CGFloat,cell:UITableViewCell){
        if #available(iOS 8.0, *) {
            tableView.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsMake(0, fSetOffset, 0, 0)
        }
        tableView.separatorInset = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0, fSetOffset, 0, 0)
    }
}




















































