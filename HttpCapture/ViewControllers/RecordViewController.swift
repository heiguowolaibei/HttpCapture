//
//  HistoryViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/26.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit
import Foundation

class RecordModel:NSObject
{
    var url = ""
    var time = ""
    var date:NSDate?
        {
        didSet{
            if let dd = date
            {
                DateFormatterManager.sharedInstance.parseStyle(4, date: dd, block: { (s) in
                    self.time = s
                })
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(url:String ,time:String,date:NSDate?=nil)
    {
        self.init()
        self.url        = url
        self.time       = time
        self.date       = date
    }
}

class HistoryCell: UITableViewCell {
    var nameLabel = UILabel()
    var dateLabel = UILabel()
    var bMark = false{
        didSet{
            relayoutSubview()
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        nameLabel.frame = CGRectMake(10, 5, 190 , 43)
        nameLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont.systemFontOfSize(15)
        nameLabel.textColor = UIColor.fromRGBA(0x333333ff)
        self.contentView.addSubview(nameLabel)
        
        dateLabel.frame = CGRectMake(self.contentView.width - 10 - 100, 5, 100 , 25)
        dateLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        dateLabel.textAlignment = NSTextAlignment.Right
        dateLabel.font = UIFont.systemFontOfSize(15)
        dateLabel.textColor = UIColor.fromRGBA(0x333333ff)
        self.contentView.addSubview(dateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.frame = CGRectMake(self.contentView.width - 10 - 100, 5, 100 , 25)
        relayoutSubview()
    }
    
    func relayoutSubview()
    {
        if bMark
        {
            nameLabel.frame = CGRectMake(10, 5, self.width - 30 , 43)
            dateLabel.hidden = true
        }
        else{
            nameLabel.frame = CGRectMake(10, 5, self.width - 120 , 43)
            dateLabel.hidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc class RecordViewController: CaptureBaseViewController,UITableViewDelegate,UITableViewDataSource {
    var tableView = UITableView()
    @objc var currentDatasource = Array<RecordModel>()
    var records = NSMutableArray()
    var currentIndex = 0
        {
        didSet{
            if self.records.count > self.currentIndex
            {
                if let ar = records[self.currentIndex] as? Array<RecordModel>
                {
                    self.currentDatasource = ar
                    self.reload()
                }
            }
        }
    }
    weak var targetVC:ToolBarWebViewController?
    var segment = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var marks = Array<RecordModel>()
//        marks.append(RecordModel(url: "http://www.google.co.jp", time: "", date: nil))
        marks.append(RecordModel(url: "http://www.jd.com", time: "", date: nil))
        marks.append(RecordModel(url: "http://wqs.jd.com", time: "", date: nil))
        marks.append(RecordModel(url: "http://wqs.jd.com/portal/sq/portal_index2.shtml?ptag=17012.4.15&ptype=4", time: "", date: nil))
        marks.append(RecordModel(url: "http://wq.jd.com/mcoss/wxmall/home?ptype=1", time: "", date: nil))       //微信一级
        marks.append(RecordModel(url: "http://wq.jd.com/mcoss/wxmall/home?ptype=3", time: "", date: nil))       //微信二级
        marks.append(RecordModel(url: "http://wq.jd.com/mcoss/wxmall/home?ptype=4", time: "", date: nil))       //手Q一级
        marks.append(RecordModel(url: "http://wq.jd.com/mcoss/wxmall/home?ptype=2", time: "", date: nil))       //手Q二级

        records = [marks,HttpCaptureManager.shareInstance().histories]
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.registerClass(HistoryCell.self, forCellReuseIdentifier: "CellID")
        tableView.tableFooterView = UIView(frame:CGRectZero)
        self.view.addSubview(tableView)
        self.navigationItem.title = "记录"
        
        segment.frame = CGRectMake(0, 0, 120, 34)
        segment.insertSegmentWithTitle("书签", atIndex: 0, animated: false)
        segment.insertSegmentWithTitle("历史记录", atIndex: 1, animated: false)
        segment.tintColor = UIColor.fromRGB(0xe11644)
        segment.selectedSegmentIndex = 0
        self.currentIndex = 0
        segment.addTarget(self, action: "segchange", forControlEvents: UIControlEvents.ValueChanged)
        segment.center = CGPointMake(self.navigationBar.width/2, self.navigationBar.height/2)
        self.navigationItem.titleView = segment
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        records[1] = HttpCaptureManager.shareInstance().histories
        self.currentIndex = self.segment.selectedSegmentIndex
    }
    
    override func useDefaultBackButton() -> Bool {
        return false;
    }
    
    func segchange() {
        self.currentIndex = self.segment.selectedSegmentIndex
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("CellID") as? HistoryCell
        if cell == nil {
            cell = HistoryCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellID")
        }
        
        if currentDatasource.count > indexPath.row {
            cell?.nameLabel.text = currentDatasource[indexPath.row].url
            cell?.dateLabel.text = currentDatasource[indexPath.row].time
        }
        
        cell?.bMark = segment.selectedSegmentIndex == 0
        cell?.nameLabel.numberOfLines = 2;
        cell?.nameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return currentDatasource.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if currentDatasource.count > indexPath.row
        {
            self.sidebarDelegate?.clearSnapShotsArray?()
            self.sidebarDelegate?.replaceWebView?()
            self.sidebarDelegate?.setToolbarURL?(currentDatasource[indexPath.row].url)
            
            if let indexpath = self.sidebarDelegate?.getSearchWebControllerIndexPath?(),let indexpath2 = self.sidebarDelegate?.getMenuItemIndexPath?(self)
            {
                self.sidebarDelegate?.selectIndexPath?(indexpath2, animationFinishBlock: { (finish) in
                    self.sidebarDelegate?.selectIndexPath?(indexpath, animationFinishBlock: { (finish) in
                        
                    })
                })
            }
        }
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
            cell.layoutMargins = UIEdgeInsetsMake(0, fSetOffset, 0, fSetOffset)
        }
        tableView.separatorInset = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0, fSetOffset, 0, fSetOffset)
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
}










































