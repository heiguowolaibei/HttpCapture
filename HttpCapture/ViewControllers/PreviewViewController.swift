//
//  PreviewViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/24.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import Foundation
import UIKit

class PreviewCell: UITableViewCell {
    var nameLabel = UILabel()
    var dateLabel = UILabel()
    var mimeLabel = UILabel()
    var statusLabel = UILabel()
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        nameLabel.frame = CGRectMake(10, 5, self.width - 10 - 75 - 44 , 65)
        nameLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.numberOfLines = 3
        nameLabel.font = UIFont.systemFontOfSize(15)
        nameLabel.textColor = UIColor.fromRGBA(0x222222ff)
        self.contentView.addSubview(nameLabel)
        
        mimeLabel.frame = CGRectMake(10, nameLabel.top + nameLabel.height + 2, 180 , 13)
        mimeLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        mimeLabel.textAlignment = NSTextAlignment.Left
        mimeLabel.font = UIFont.systemFontOfSize(13)
        mimeLabel.textColor = UIColor.fromRGBA(0xe11644ff)
        self.contentView.addSubview(mimeLabel)
        
        statusLabel.frame = CGRectMake(mimeLabel.left + mimeLabel.width + 10, nameLabel.top + nameLabel.height + 2, 120 , 13)
        statusLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        statusLabel.textAlignment = NSTextAlignment.Left
        statusLabel.font = UIFont.systemFontOfSize(13)
        statusLabel.textColor = UIColor.fromRGBA(0x22ee77ff)
        self.contentView.addSubview(statusLabel)
        
        dateLabel.frame = CGRectMake(self.width - 10 - nameLabel.width , 5 , 75 , 65)
        dateLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        dateLabel.numberOfLines = 3
        dateLabel.textAlignment = NSTextAlignment.Right
        dateLabel.font = UIFont.systemFontOfSize(13)
        dateLabel.textColor = UIColor.fromRGBA(0x333333ff)
        self.contentView.addSubview(dateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRectMake(10, 5, self.width - 10 - 75 - 44 , 65)
        dateLabel.frame = CGRectMake(10 + nameLabel.width + 10 , 5 , 75 , 65)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@objc class PreviewViewController: CaptureBaseViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    var tableView = UITableView()
    var searchBar = UISearchBar()
    var tempEntries:NSMutableArray?
    var beginFilter = false;
    @objc var entries = NSMutableArray()
        {
        didSet{
            self.searchBar.hidden = false;
            self.reload()
        }
    }
    
    func configTempEntries() {
        tempEntries = NSMutableArray(array: entries)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView(frame:CGRectZero)
        tableView.registerClass(PreviewCell.self, forCellReuseIdentifier: "CellID")
        self.view.addSubview(tableView)
        
        rightBtn.frame = CGRectMake(0, 0, 44, 44)
        rightBtn.contentHorizontalAlignment = .Right
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
        rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
        rightBtn.setTitle("清除", forState: UIControlState.Normal)
        rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        let img:UIImage = UIImage.imageWithColor(UIColor.fromRGBA(0xf2f2f2ff), size: CGSizeMake(WXDevice.width, 64))
        searchBar.setBackgroundImage(img, forBarPosition: .Any, barMetrics: UIBarMetrics.Default)
        searchBar.barTintColor = UIColor.fromRGBA(0xf2f2f2ff)
        searchBar.delegate = self
        searchBar.placeholder = "过滤"
        self.tableView.tableHeaderView = searchBar
        
        self.navigationItem.title = "预览"
    }
    
    func scrollToTop(){
        self.tableView.scrollRectToVisible(CGRectMake(0, 0, self.view.width, 10), animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
        
        if scrollView.contentOffset.y > 150
        {
            if let btn = self.view.scrollToTopButton where btn.alpha == 0
            {
                self.view.bringSubviewToFront(btn)
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.view.scrollToTopButton?.alpha = 1
                })
            }
        }
        else{
            if self.view.scrollToTopButton?.alpha == 1
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.view.scrollToTopButton?.alpha = 0
                    }, completion: { (finished) -> Void in
                        
                })
            }
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let button = searchBar.cancelButton
        let attri = NSAttributedString(string: "取消", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(16.0),NSForegroundColorAttributeName:UIColor.customTextColor()])
        button?.setAttributedTitle(attri, forState: UIControlState.Normal)
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let temp = tempEntries
        {
            if searchText.length == 0 {
                self.entries = NSMutableArray(array:temp)
            }
            else{
                let newar = temp.filter({ (entry) -> Bool in
                    if let _entry = entry as? Entry
                    {
                        if (_entry.request.url.lowercaseString as NSString).rangeOfString(searchText.lowercaseString).length > 0 || (_entry.response.content.mimeType.lowercaseString as NSString).rangeOfString(searchText.lowercaseString).length > 0 ||
                            ("\(_entry.response.status)".lowercaseString as NSString).rangeOfString(searchText.lowercaseString).length > 0
                        {
                            return true;
                        }
                    }
                    
                    return false
                })
                self.entries = NSMutableArray(array: newar)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if let temp = tempEntries
        {
            self.entries = NSMutableArray(array: temp)
        }
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
        
        self.searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: false)
        self.searchBar.resignFirstResponder()
    }
    
    override func useDefaultBackButton() -> Bool{
        return true;
    }
    
    override func rightButtonClick(item: UIButton) {
        HttpCaptureManager.shareInstance().removeEntries(self.entries) { (rs) in
            self.entries.removeAllObjects()
            self.tempEntries?.removeAllObjects()
            self.tempEntries = nil
            self.tableView.reloadData()
            self.searchBar.text = ""
            self.searchBar.hidden = true;
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("CellID") as? PreviewCell
        if cell == nil {
            cell = PreviewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellID")
        }
        
        if self.entries.count > indexPath.row {
            if let entry = self.entries[indexPath.row] as? Entry
            {
                cell?.nameLabel.text = entry.request.url
                cell?.dateLabel.text = entry.getStartTime()
                cell?.mimeLabel.text = "类型：" + entry.response.content.mimeType
                cell?.statusLabel.text = "状态码：\(entry.response.status)"
            }
        }
        
        cell?.nameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 93;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.entries.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let entry = self.entries.objectAtIndex(indexPath.row) as? Entry
        {
            let captureVC = CaptureDetailViewController()
            captureVC.entry = entry
            self.navigationController?.pushViewController(captureVC, animated: true)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if let key = entries.allKeys[section] as? String
//        {
//            let header = UIButton(frame:CGRectMake(0,0,self.view.width,30))
//            header.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//            header.setTitle("    \(key)", forState: UIControlState.Normal)
//            header.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//            header.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
//            header.titleLabel?.numberOfLines = 1
//            header.tag = 1000 + section
//            header.addTarget(self, action: "exposure:", forControlEvents: UIControlEvents.TouchUpInside)
//            return header
//        }
        
        return nil;
    }
    
    func exposure(btn:UIButton){
//        if searchBar.isFirstResponder()
//        {
//            return;
//        }
//        let tag = btn.tag - 1000
//        if tag >= 0 && self.entries.allKeys.count > tag
//        {
//            if let key = self.entries.allKeys[tag] as? String,let ar = self.entries.objectForKey(key) as? Array<Entry>
//            {
//                if ar.count > 0
//                {
//                    self.entries.setObject(Array<Entry>(), forKey: key)
//                }
//                else{
//                    if let temp = self.tempEntries,let values = temp.objectForKey(key) as? Array<Entry>
//                    {
//                        var arr = Array<Entry>()
//                        arr.appendContentsOf(values)
//                        self.entries.setObject(arr, forKey: key)
//                    }
//                }
//                DPrintln("btn = \(tag);\(ar.count);")
//                for (key,value) in entries {
//                    DPrintln("key value =\(key as! String);\((value as! Array<Entry>).count)")
//                }
//                self.tableView.reloadSections(NSIndexSet(index: tag), withRowAnimation: UITableViewRowAnimation.Automatic)
//                DPrintln("btn2 = \(tag);\(ar.count)")
//            }
//        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
    
    func reload() {
        self.tableView.reloadData()
    }
    
    deinit
    {
        self.searchBar.resignFirstResponder()
    }
}









































