//
//  HostViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/13.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class HostModel:NSObject{
    var name = ""
    var value = ""
    var envName = ""
    var enable = true
    var index = -1
    
    func encodeWithCoder(_aCoder: NSCoder) {
        _aCoder.encodeObject(value,forKey:"value")
        _aCoder.encodeObject(name,forKey:"name")
        _aCoder.encodeObject(envName,forKey:"envName")
        _aCoder.encodeObject(NSNumber(bool: enable),forKey:"enable")
    }

    override init() {
        super.init()
    }
    
    func isLegal() -> Bool{
        if self.name.componentsSeparatedByString(".").count < 2{
            return false
        }
        if self.value.componentsSeparatedByString(".").count < 4{
            return false
        }
        return true
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()

        if let id_ = aDecoder.decodeObjectForKey("value") as? String{
            self.value = id_
        }
        if let name_ = aDecoder.decodeObjectForKey("name") as? String{
            self.name = name_
        }
        if let name_ = aDecoder.decodeObjectForKey("envName") as? String{
            self.envName = name_
        }
        if let obj = aDecoder.decodeObjectForKey("enable") as? NSNumber{
            self.enable = obj.boolValue
        }
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let model = HostModel()
        model.value = self.value
        model.name = self.name
        model.envName = self.envName
        model.enable = self.enable
        
        return model
    }
}

class AddTagViewController:CaptureBaseViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate
{
    var tableView:UITableView?
    var hostArr = ["开发环境","测试环境","预发布环境","正式环境"]
    var addTagBlock:((model:HostModel) -> Void)?
    var headerView:UIView?
    var titleView:UIView?
    weak var superViewCtrl:UIViewController?
    var hostModel=HostModel()
    weak var model:HostModel?
    private var _cancelBtn: UIButton!
    private var _titleLabel: UILabel!
    private var _confrimBtn: UIButton!
    private var cancelBtn: UIButton {
        get{
            if _cancelBtn == nil{
                _cancelBtn = UIButton()
                _cancelBtn.backgroundColor = UIColor.clearColor()
                _cancelBtn.setTitle("取消", forState: .Normal)
                _cancelBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: .Normal)
                _cancelBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
                _cancelBtn.addTarget(self, action: "clickBtn:", forControlEvents: .TouchUpInside)
            }
            return _cancelBtn
            
        }
        set{
            _cancelBtn = newValue
        }
    }
    private var titleLabel: UILabel {
        get{
            if _titleLabel == nil{
                _titleLabel = UILabel()
                _titleLabel.textAlignment = .Center;
                _titleLabel.textColor = UIColor.fromRGBA(0x333333ff)
                _titleLabel.text = "添加标签"
                _titleLabel.backgroundColor = UIColor.clearColor()
                _titleLabel.font = UIFont.systemFontOfSize(16)
            }
            return _titleLabel
            
        }
        set{
            _titleLabel = newValue
        }
    }
    
    private var confrimBtn: UIButton {
        get{
            if _confrimBtn == nil{
                _confrimBtn = UIButton()
                _confrimBtn.backgroundColor = UIColor.clearColor()
                _confrimBtn.setTitle("完成", forState: .Normal)
                _confrimBtn.setTitleColor(UIColor.fromRGBA(0xe11644ff), forState: .Normal)
                _confrimBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
                _confrimBtn.addTarget(self, action: "clickBtn:", forControlEvents: .TouchUpInside)
            }
            return _confrimBtn
            
        }
        set{
            _confrimBtn = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        tableView?.delegate = self;
        tableView?.dataSource = self;
        tableView?.tableFooterView = UIView(frame:CGRectZero)
        tableView?.backgroundColor = UIColor.fromRGB(0xf5f5f5)
        tableView?.showsVerticalScrollIndicator = false
        tableView?.scrollEnabled = false
        self.view.addSubview(tableView!)
        
        let yInteval:CGFloat = 13;
        headerView = UIView(frame: CGRectMake(0,0,self.view.width,yInteval * 4 + 44*3))
        headerView?.backgroundColor = UIColor.fromRGB(0xf5f5f5)
        
        titleView = UIView(frame: CGRectMake(0,0,self.view.width,44))
        titleView?.backgroundColor = UIColor.fromRGB(0xeeeeee)
        
        titleView?.addSubview(self.cancelBtn)
        titleView?.addSubview(self.titleLabel)
        titleView?.addSubview(self.confrimBtn)
        
        let arr = ["输入域名","输入ip","选择环境"]
        var yOffset = yInteval;
        var xOffset:CGFloat = 10;
        for (index,item) in arr.enumerate() {
            let textField = UITextField(frame: CGRectMake(xOffset,yOffset + CGFloat(index) * (yInteval+44),self.view.width-2*10,44))
            textField.delegate = self
            textField.backgroundColor = UIColor.fromRGB(0xeeeeee)
            textField.placeholder = "      " + item
            textField.textColor = UIColor.fromRGB(0x333333)
            textField.textAlignment = NSTextAlignment.Center
            textField.layer.cornerRadius = 44/2;
            textField.tag = index + 1000
            if let model = self.model
            {
                if index == 0 {
                    textField.text = "      " + model.name
                }
                if index == 1 {
                    textField.text = "      " + model.value
                }
                if index == 2 {
                    textField.text = "      " + model.envName
                }
            }
            
            let rightV = UIButton(frame: CGRectMake(textField.width - 30, 2, 30, 30))
            rightV.setImage(CommonImageCache.getImage(named: "标签删除"), forState: UIControlState.Normal)
            rightV.addTarget(self, action: "remove:", forControlEvents: UIControlEvents.TouchUpInside)
            textField.rightView = rightV
            rightV.tag = index + 100
            textField.rightViewMode = .Always
            
            headerView?.addSubview(textField)
        }
        
        tableView?.tableHeaderView = headerView
        self.view.addSubview(titleView!)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let tag = textField.tag - 1000
        if tag < 3 {
            let vc = TagSearchViewController()
            var type = SearchBtnType.Host
            if tag == 1
            {
                type = SearchBtnType.Ip
            }
            else if tag == 2
            {
                type = SearchBtnType.HostType
                var items = [HostModel]()
                for item in hostArr
                {
                    let info = HostModel()
                    info.name = item
                    items.append(info)
                }
                vc.dataArray = items;
            }
            vc.type = type
            vc.originStr = textField.text
            vc.searchBlock = {[weak self](text: String) -> Void in
                textField.text = "      " + text
            }
            self.superViewCtrl?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return false;
    }
    
    func remove(btn:UIButton) {
        let tag = btn.tag - 100
        if let field = self.headerView?.viewWithTag(tag + 1000) as? UITextField
        {
            field.text = ""
        }
    }
    
    func clickBtn(btn:UIButton)  {
        if let vc = self.superViewCtrl
        {
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectMake(0, vc.view.height, self.view.width, self.view.height)
            }) { (finish) in
                
            }
        }
        
        if btn == self.confrimBtn {
            if let field = self.headerView?.viewWithTag(1000) as? UITextField,let text = field.text
            {
                hostModel.name = text.trimSpaceNewLine().lowercaseString
            }
            if let field = self.headerView?.viewWithTag(1001) as? UITextField,let text = field.text
            {
                hostModel.value = text.trimSpaceNewLine()
            }
            if let field = self.headerView?.viewWithTag(1002) as? UITextField,let text = field.text
            {
                hostModel.envName = text.trimSpaceNewLine()
            }
            
            if let m = model
            {
                hostModel.index = m.index
            }
            
            if addTagBlock != nil {
                addTagBlock?(model: hostModel)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationBar.removeFromSuperview()
        tableView?.frame = CGRectMake(0, 44, self.view.width, self.view.height - 44)
        titleView?.frame = CGRectMake(0, 0, self.view.width, 44)
        _cancelBtn.frame = CGRectMake(0, 0, 44, 44)
        _confrimBtn.frame = CGRectMake(self.view.width-44, 0, 44, 44)
        _titleLabel.frame = CGRectMake(0, 0, 150, 44)
        _titleLabel.center = CGPointMake(self.view.width/2, 44/2)
    }
    
    override func useDefaultBackButton() -> Bool{
        return false;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("CellID")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellID")
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.None
        
        if hostArr.count > indexPath.row
        {
            cell?.textLabel?.text = hostArr[indexPath.row]
            cell?.textLabel?.textColor = UIColor.fromRGB(0x333333)
        }
        
        cell?.textLabel?.numberOfLines = 1;
        cell?.textLabel?.textAlignment = NSTextAlignment.Center
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell?.contentView.backgroundColor = UIColor.fromRGB(0xf5f5f5)
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if hostArr.count > indexPath.row
        {
            hostModel.envName = hostArr[indexPath.row]
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0;
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
            tableView?.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsMake(0, fSetOffset, 0, 0)
        }
        tableView?.separatorInset = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0, fSetOffset, 0, 0)
    }
}

class AddHostController:TextViewController{
    var hostLabel = UILabel()
    var addHostsBlock:((models:[HostModel]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hostLabel.frame = CGRectMake(10, 7 + 64, self.view.width - 20, 30)
        hostLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        hostLabel.textAlignment = NSTextAlignment.Left
        hostLabel.numberOfLines = 2
        hostLabel.text = "请在下方输入ip和域名，ip和域名之间请用空格隔开"
        hostLabel.font = UIFont.systemFontOfSize(14)
        hostLabel.textColor = UIColor.fromRGBA(0x333333ff)
        self.view.addSubview(hostLabel)
        
        rightBtn.frame = CGRectMake(0, 0, 44, 44)
        rightBtn.contentHorizontalAlignment = .Right
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
        rightBtn.setTitle("完成", forState: UIControlState.Normal)
        rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
        rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    override func rightButtonClick(btn:UIButton)
    {
        MBProgressHUDHelper.sharedMBProgressHUDHelper.showAnimated(true, text: "解析host信息")
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            let models = self.textView.text.parseText()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                MBProgressHUDHelper.sharedMBProgressHUDHelper.hidden(nil, animation: false)
                if self.addHostsBlock != nil
                {
                    self.addHostsBlock?(models:models)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        })
        
    }
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.textView.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hostLabel.frame = CGRectMake(10, 7 + 64, self.view.width - 20, 30)
        textView.frame = CGRectMake(10, hostLabel.bottom + 10 , self.view.width - 10*2, self.view.height - (hostLabel.bottom + 10) - 10)
    }
}

class HostViewController: CaptureBaseViewController,UITableViewDelegate,UITableViewDataSource {
    var tempDatasource:NSMutableDictionary?
    var datasource = NSMutableDictionary()
        {
        didSet{
            self.datasourceChanged(true)
        }
    }
    var tableView:UITableView?
    var addHostsBtn:UIButton?
    var headerKeys = [String]()
        {
        didSet{
            
        }
    }
    var path = ""
    let queue = dispatch_queue_create("adsf", DISPATCH_QUEUE_SERIAL)
    let writequeue = dispatch_queue_create("writequeue", DISPATCH_QUEUE_SERIAL)
    var popView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "host替换"
        
        self.view.backgroundColor = UIColor.fromRGB(0xf5f5f5)
        self.automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView?.delegate = self;
        tableView?.dataSource = self;
        tableView?.tableFooterView = UIView(frame:CGRectZero)
        tableView?.backgroundColor = UIColor.fromRGB(0xf5f5f5)
        self.view.addSubview(tableView!)
        
        addHostsBtn = UIButton(frame: CGRectMake(10, self.view.height - 44 - 10, self.view.width - 20, 44))
        addHostsBtn?.setTitle("一键更新host", forState: UIControlState.Normal)
        addHostsBtn?.layer.cornerRadius = 3;
        addHostsBtn?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addHostsBtn?.backgroundColor = UIColor.colorWithRGB(red: 0, green: 122, blue: 255)
        addHostsBtn?.addTarget(self, action: "addhosts", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(addHostsBtn!)
        
        rightBtn.frame = CGRectMake(0, 0, 44, 44)
        rightBtn.contentHorizontalAlignment = .Right
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
        rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
        rightBtn.setImage(CommonImageCache.getImage(named: "add_brand_tag"), forState: UIControlState.Normal)
        rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem
        
//        MBProgressHUDHelper.sharedMBProgressHUDHelper.showAnimated(true, text: "解析host信息")
        dispatch_async(queue) {
            
//            if let path = NSBundle.mainBundle().pathForResource("hosts", ofType: "txt")
//            {
//                let stext = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
//                if let models = stext?.parseText()
//                {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        DPrintln("时间1 \(NSDate())")
//                        for item in models
//                        {
//                            DPrintln("时间 \(NSDate())")
//                            self.appendModel(item)
//                        }
//                        DPrintln("时间2 \(NSDate())")
//                    })
//                }
//            }
            
            let path = HttpCaptureManager.shareInstance().hostPath.stringByAppendingString("/host.plist")
            if let obj = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Dictionary<String,Array<HostModel>>
            {
                dispatch_async(dispatch_get_main_queue(), {
                    for value in obj.values
                    {
                        for item in value
                        {
                            self.appendModel(item)
                        }
                    }
                    self.datasourceChanged(true)
                    MBProgressHUDHelper.sharedMBProgressHUDHelper.hidden(nil, animation: false)
                })
            }
            else{
                if let path = NSBundle.mainBundle().pathForResource("hosts", ofType: "plist")
                {
                    if let datasource = NSDictionary(contentsOfFile: path)
                    {
                        for (_,value) in datasource
                        {
                            if let ar = value as? Array<Dictionary<String,String>>
                            {
                                dispatch_async(dispatch_get_main_queue(), {
                                    for item in ar
                                    {
                                        self.appendModel(HostModel(keyValues:item))
                                    }
                                    self.datasourceChanged(true)
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func writeFile() {
        let path = HttpCaptureManager.shareInstance().hostPath.stringByAppendingString("/host.plist")
        
        let dic = NSMutableDictionary(dictionary: self.datasource)
        dispatch_async(writequeue) {
            NSKeyedArchiver.archiveRootObject(dic, toFile: path)
        }
    }
    
    func addhosts() {
        let vc = AddHostController()
        vc.sTitle = "增加host"
        vc.addHostsBlock = {[weak self](models:[HostModel]) -> Void in
            self?.datasource.removeAllObjects()
            for model in models{
                self?.appendModel(model)
            }
        }
        vc.text = getHostText()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getHostText() -> String {
        var stext = ""
        for value in self.datasource.allValues
        {
            if let ar = value as? [HostModel]
            {
                for item in ar
                {
                    stext += item.value + "\t " + item.name + "\r\n"
                }
            }
        }
        
        return stext
    }
    
    override func useDefaultBackButton() -> Bool{
        return false;
    }
    
    override func rightButtonClick(item: UIButton) {
        self.showPopView(nil)
    }
    
    func showPopView(m:HostModel?){
        popView?.removeFromSuperview()
        popView?.viewController()?.removeFromParentViewController()
        
        let vc = AddTagViewController()
        vc.superViewCtrl = self;
        vc.model = m
        popView = vc.view
        popView?.frame = CGRectMake(0, self.view.height, self.view.width, 44*3+13*4+44)
        self.view.addSubview(popView!)
        self.addChildViewController(vc)
        
        vc.addTagBlock = {[weak self](model:HostModel) -> Void in
            guard let newself = self else {return}
            newself.appendModel(model)
            newself.datasourceChanged(true)
        }
        
        if let vc = popView
        {
            UIView.animateWithDuration(0.3, animations: {
                vc.frame = CGRectMake(0, self.view.height - vc.height, self.view.width, vc.height)
                }, completion: { (finish) in
                    //                    self.view.bringSubviewToFront(self.popView!)
            })
        }
    }
    
    func appendModel(model:HostModel)
    {
        if model.name.length == 0 || model.value.length == 0 || model.envName.length == 0
        {
            return;
        }
        if !model.isLegal()
        {
            MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("请输入合乎规范的host信息")
            return;
        }
        if var ar = self.datasource.objectForKey(model.envName) as? NSMutableArray
        {
            if model.index >= 0 {
                ar.removeObjectAtIndex(model.index)
            }
            ar.addObject(model)
        }
        else{
            let ar = NSMutableArray()
            ar.addObject(model)
            self.datasource.setObject(ar, forKey: model.envName)
        }
    }
    
    func datasourceChanged(needUpdateUI:Bool)  {
        self.tempDatasource = NSMutableDictionary(dictionary: self.datasource)
        if let keys = self.datasource.allKeys as? [String]
        {
            self.headerKeys = keys
        }
        
        var models = Array<HostModel>()
        for (_,value) in self.datasource
        {
            if let ar = value as? [HostModel]
            {
                models.appendContentsOf(ar)
            }
        }
        HttpCaptureManager.shareInstance().appendHostIp(models)
        
        if needUpdateUI {
            self.tableView?.reloadData()
        }
        self.writeFile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView?.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64 - 44 - 20)
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
            if let ar = datasource.objectForKey(key) as? Array<HostModel> where ar.count > indexPath.row
            {
                let data = ar[indexPath.row]
                cell?.textLabel?.text = data.name
                cell?.detailTextLabel?.text = data.value
            }
        }
        
        cell?.textLabel?.numberOfLines = 1;
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        cell?.detailTextLabel?.numberOfLines = 1;
        cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        
        return cell!
    }
    
    @available(iOS 8.0, *)
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        var title = "禁用"
        if headerKeys.count > indexPath.section
        {
            let key = headerKeys[indexPath.section]
            if var ar = self.datasource[key] as? [HostModel]
            {
                let model = ar[indexPath.row]
                title = model.enable ? "禁用" : "启用"
            }
        }
        let enable = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: title) { (action, indexpath) in
            self.enableIndexpath(indexPath)
        }
        enable.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "删除") { (action, indexpath) in
            print("delete:")
            
            self.deleteIndexpath(indexPath)
        }
        return [enable,delete];
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if headerKeys.count > section
        {
            let key = headerKeys[section]
            if let ar = datasource.objectForKey(key) as? Array<HostModel>
            {
                return ar.count
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if headerKeys.count > indexPath.section
        {
            if let key = headerKeys[indexPath.section] as? String
            {
                if let ar = datasource[key] as? Array<HostModel>
                {
                    if ar.count > indexPath.row
                    {
                        let data = ar[indexPath.row]
                        data.index = indexPath.row
                        self.showPopView(data)
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
                header.tag = section + 555
//                header.addTarget(self, action: "exposure:", forControlEvents: UIControlEvents.TouchUpInside)
                return header
            }
        }
        
        return nil;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sections = 0
        for (_,value) in datasource
        {
            if let ar = value as? NSArray where ar.count > 0
            {
                sections += 1
            }
        }
        return sections
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        self.onSetMarginOrInset(true, fSetOffset: 10, cell: cell)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.Delete
    }
    
    func enableIndexpath(indexPath:NSIndexPath)
    {
        if headerKeys.count > indexPath.section
        {
            let key = headerKeys[indexPath.section]
            if var ar = self.datasource[key] as? [HostModel]
            {
                let model = ar[indexPath.row]
                model.enable = !model.enable;
                self.datasourceChanged(true)
            }
        }
    }
    
    func deleteIndexpath(indexPath:NSIndexPath)
    {
        if headerKeys.count > indexPath.section
        {
            let key = headerKeys[indexPath.section]
            if var ar = self.datasource[key] as? [HostModel]
            {
                ar.removeAtIndex(indexPath.row)
                if ar.count == 0 {
                    self.datasource.removeObjectForKey(key)
                }
                else{
                    self.datasource.setObject(ar, forKey: key)
                }
                
                self.datasourceChanged(true)
            }
        }
    }
    
//    func exposure(btn:UIButton){
//        let tag = btn.tag - 555
//        if tag >= 0 && headerKeys.count > tag
//        {
//            if let key = headerKeys[tag] as? String,let ar = self.datasource.objectForKey(key) as? Array<HostModel>
//            {
//                if ar.count > 0
//                {
//                    self.datasource.setObject(Array<HostModel>(), forKey: key)
//                }
//                else{
//                    if let temp = self.tempDatasource,let values = temp.objectForKey(key) as? Array<HostModel>
//                    {
//                        var arr = Array<HostModel>()
//                        arr.appendContentsOf(values)
//                        self.datasource.setObject(arr, forKey: key)
//                    }
//                }
//                for (key,value) in datasource {
//                    DPrintln("key value =\(key as! String);\((value as! Array<Entry>).count)")
//                }
//                self.datasourceChanged()
//                self.tableView?.reloadSections(NSIndexSet(index: tag), withRowAnimation: UITableViewRowAnimation.Automatic)
//            }
//        }
//    }
    
    func onSetMarginOrInset(bSetTable:Bool,fSetOffset:CGFloat,cell:UITableViewCell){
        if #available(iOS 8.0, *) {
            tableView?.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsMake(0, fSetOffset, 0, 0)
        }
        tableView?.separatorInset = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsMake(0, fSetOffset, 0, 0)
    }
    
    
}
