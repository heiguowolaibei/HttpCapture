//
//  SettingViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/7.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class IndexSection:NSObject{
    var row = 0;
    var section = 0;
}

class SettingViewController: CaptureBaseViewController,UITableViewDelegate,UITableViewDataSource {
    var tableView = UITableView()
    var headerValues = NSMutableDictionary()
    var selectIndexpath = IndexSection()
    let browserName = "手机浏览器"
    let wxName = "微信"
    let qqName = "手q"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerValues.setObject([browserName,wxName,qqName], forKey: "环境切换")
        
        selectIndexpath.row = 0;
        selectIndexpath.section = 0;
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView(frame:CGRectZero)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        self.view.addSubview(tableView)
    }
    
    override func useDefaultBackButton() -> Bool{
        return false;
    }
    
    func scrollToTop(){
        self.tableView.scrollRectToVisible(CGRectMake(0, 0, self.view.width, 10), animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("CellID")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellID")
        }
        
        let keys = headerValues.allKeys
        if keys.count > indexPath.section {
            if let key = keys[indexPath.section] as? String, let ar = headerValues[key] as? Array<String>
            {
                cell?.textLabel?.text = ar[indexPath.row]
            }
        }
        
        cell?.textLabel?.numberOfLines = 3;
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell?.accessoryType = UITableViewCellAccessoryType.None
        
        if indexPath.row == selectIndexpath.row && indexPath.section == selectIndexpath.section {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let keys = headerValues.allKeys
        if keys.count > section {
            if let key = keys[section] as? String, let ar = headerValues[key] as? Array<String>
            {
                return ar.count;
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let number = tableView.numberOfRowsInSection(indexPath.section)
        for var i=0;i < number;i=i+1
        {
            let newIndexpath = NSIndexPath(forRow: i, inSection: indexPath.section)
            tableView.cellForRowAtIndexPath(newIndexpath)?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        let keys = headerValues.allKeys
        if keys.count > indexPath.section {
            if let key = keys[indexPath.section] as? String, let _ = headerValues[key] as? Array<String>
            {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        
        self.configUAPlatform(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let key = headerValues.allKeys[section] as? String
        {
            let header = UIButton(frame:CGRectMake(0,0,self.view.width,30))
            header.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            header.setTitle("    \(key)", forState: UIControlState.Normal)
            header.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            header.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
            header.titleLabel?.numberOfLines = 1
            header.tag = 1000 + section
//            header.addTarget(self, action: "exposure:", forControlEvents: UIControlEvents.TouchUpInside)
            return header
        }
        
        return nil;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return headerValues.allKeys.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        self.onSetMarginOrInset(true, fSetOffset: 10, cell: cell)
    }
    
    func configUAPlatform(indexPath:NSIndexPath) {
        let keys = headerValues.allKeys
        if keys.count > indexPath.section {
            if let key = keys[indexPath.section] as? String, let ar = headerValues[key] as? Array<String>
            {
                if ar[indexPath.row] == browserName
                {
                    HttpCaptureManager.shareInstance().platform = UAPlatform.keepSameUA
                }
                else if ar[indexPath.row] == wxName
                {
                    HttpCaptureManager.shareInstance().platform = UAPlatform.WeixinUA
                }
                else if ar[indexPath.row] == qqName
                {
                    HttpCaptureManager.shareInstance().platform = UAPlatform.QQUA
                }
            }
        }
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
    
    func reload() {
        self.tableView.reloadData()
    }
    
    deinit
    {
        
    }
}
