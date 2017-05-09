//
//  UploadViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/26.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class UploadCell: UITableViewCell {
    var selectBtn = UIButton()
    var nameLabel = UILabel()
    var sizeLabel = UILabel()
    var dateLabel = UILabel()
    let imgWidHei:CGFloat = 40
    var showSelect = true{
        didSet{
            self.relayoutSubviews()
        }
    }
    var subselected = false
    {
        didSet{
            self.changeImg(subselected)
        }
    }
    
    func changeImg(selected:Bool) {
        if selected {
            selectBtn.setImage(CommonImageCache.getImage(named: "1-衣物选中状态"), forState: UIControlState.Normal)
        }
        else{
            selectBtn.setImage(CommonImageCache.getImage(named: "搭配页管理未选择圈"), forState: UIControlState.Normal)
        }
    }
    
    func relayoutSubviews(){
        if showSelect{
            selectBtn.frame = CGRectMake(10, self.height/2-imgWidHei/2 , imgWidHei, imgWidHei)
            selectBtn.hidden = false
            sizeLabel.frame = CGRectMake(self.contentView.width - 10 - 100, 5, 100 , 25)
            dateLabel.frame = CGRectMake(self.contentView.width - 10 - 160, sizeLabel.bottom + 5, 160 , 25)
            nameLabel.frame = CGRectMake(10 + selectBtn.width+10, 5, 180 , 25)
        }
        else{
            selectBtn.hidden = true
            sizeLabel.frame = CGRectMake(self.contentView.width - 10 - 100, 5, 100 , 25)
            dateLabel.frame = CGRectMake(self.contentView.width - 10 - 160, sizeLabel.bottom + 5, 160 , 25)
            nameLabel.frame = CGRectMake(10, 5, 180 , 25)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        selectBtn.frame = CGRectMake(10, self.height/2-imgWidHei/2 , imgWidHei, imgWidHei)
        selectBtn.setImage(CommonImageCache.getImage(named: "搭配页管理未选择圈"), forState: UIControlState.Normal)
        let offset:CGFloat = 8
        selectBtn.imageEdgeInsets = UIEdgeInsetsMake(offset, offset, offset, offset)
        self.contentView.addSubview(selectBtn)
        
        nameLabel.frame = CGRectMake(10 + selectBtn.width+10, 5, 180 , 25)
        nameLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont.systemFontOfSize(15)
        nameLabel.numberOfLines = 2;
        nameLabel.textColor = UIColor.fromRGBA(0x333333ff)
        self.contentView.addSubview(nameLabel)
        
        sizeLabel.frame = CGRectMake(self.contentView.width - 10 - 100, 5, 100 , 25)
        sizeLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        sizeLabel.textAlignment = NSTextAlignment.Right
        sizeLabel.font = UIFont.systemFontOfSize(15)
        sizeLabel.textColor = UIColor.fromRGBA(0x333333ff)
        self.contentView.addSubview(sizeLabel)
        
        dateLabel.frame = CGRectMake(self.contentView.width - 10 - 160, sizeLabel.bottom + 5, 160 , 25)
        dateLabel.backgroundColor = UIColor.fromRGBA(0xffffffff)
        dateLabel.textAlignment = NSTextAlignment.Right
        dateLabel.font = UIFont.systemFontOfSize(15)
        dateLabel.textColor = UIColor.fromRGBA(0x333333ff)
        self.contentView.addSubview(dateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectBtn.frame = CGRectMake(10, self.height/2-imgWidHei/2 , imgWidHei, imgWidHei)
        sizeLabel.frame = CGRectMake(self.contentView.width - 10 - 100, 5, 100 , 25)
        dateLabel.frame = CGRectMake(self.contentView.width - 10 - 160, sizeLabel.bottom + 5, 160 , 25)
        
//        UITableViewCellDeleteConfirmationView
        self.subvi(self)
        
    }
    
    func subvi(vi:UIView) -> UIView? {
        for subview in vi.subviews
        {
            DPrintln("String(subview.dynamicType)=\(String(subview.dynamicType))")
            if String(subview.dynamicType) == "UITableViewCellDeleteConfirmationView"
            {
                DPrintln("asfafqwe")
                return subview;
            }
            else{
                self.subvi(subview)
            }
        }
        
        return nil;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class UploadModel:NSObject{
    var fileName = ""
    var fileSize = ""
    var fileDate = ""
    var path = ""
    var selected = false
}

@objc class UploadViewController: CaptureBaseViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate
{
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    let af = AFHTTPSessionManager()
    var verifyImage = UIImageView()
    var textfield = UITextField()
    var uploadBtn = UIButton()
    var key = ""
    @objc var tableView = UITableView()
    var headerView = UIView()
    var objects = Array<UploadModel>()
    var documentInteractionController:UIDocumentInteractionController?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.config()
        
        self.loadData()
        
        self.loadFiles()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadFiles", name: AppConfiguration.NotifyNames.refreshFileNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func useDefaultBackButton() -> Bool {
        return true
    }
    
    func loadFiles()  {
        objects.removeAll()
        let contentCachePach = HttpCaptureManager.shareInstance().cachePath
        let fileManager = NSFileManager.defaultManager()
        var error : NSError?
        let dic = fileManager.WQcontentsOfDirectoryAtPath(contentCachePach, error: &error)
        var dateModels = [Int64:UploadModel]()
        var dateArray:[Int64] = []
        if let files = dic
        {
            for fileName in files{
                if fileName.containsString(".txt")
                {
                    continue
                }
                let model = UploadModel()
                let filePath = contentCachePach.stringByAppendingPathComponent(fileName)
                var properties = fileManager.WQattributesOfItemAtPath(filePath, error: &error)
                if properties != nil
                {
                    let obj: AnyObject? = properties![NSFileModificationDate]
                    
                    if let size = properties![NSFileSize] as? Double
                    {
                        let ss = NSString(format: "%0.2f", size/1024) as String;
                        model.fileSize = "\(ss)KB"
                    }
                    model.fileName = fileName
                    
                    if let mdate = obj as? NSDate
                    {
                        DateFormatterManager.sharedInstance.parseStyle(0, date: mdate, block: { (s) in
                            model.fileDate = s
                        })
                        if let snumber = NSURL(fileURLWithPath:filePath).lastPathComponent?.filterNumber(),let number = Int64(snumber)
                        {
                            dateArray.append(number)
                            dateModels[number] = model;
                        }
                    }
                    model.path = HttpCaptureManager.shareInstance().cachePath + "/\(fileName)"
                }
            }
        }
        dateArray.sortInPlace{$0 < $1}
        for var i = 0 ; i < dateArray.count;i++
        {
            let time = dateArray[i]
            if let m = dateModels[time]
            {
                objects.append(m)
            }
        }
        
        if objects.count > 0 {
            self.tableView.hidden = false;
            self.tableView.reloadData()
            
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC) * Int64(1)/5)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        else{
            self.tableView.hidden = true;
            MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("没有har文件", delayTime: 3)
        }
    }
    
    func config() {
        
        self.view.backgroundColor = UIColor.fromRGB(0xeeeeee)
        
        verifyImage.backgroundColor = UIColor.lightGrayColor()
        verifyImage.userInteractionEnabled = true
        verifyImage.contentMode = UIViewContentMode.ScaleToFill
        verifyImage.layer.cornerRadius = 3;
        verifyImage.layer.masksToBounds = true
        verifyImage.frame = CGRectMake(10, 10, 90, 44)
        verifyImage.userInteractionEnabled = true
        headerView.addSubview(verifyImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tap:")
        verifyImage.addGestureRecognizer(tapGesture)
        
        textfield.layer.borderColor = UIColor.fromRGB(0x222222).CGColor
        textfield.layer.borderWidth = 1/WXDevice.scale
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.delegate = self;
        textfield.frame = CGRectMake(verifyImage.width + 2*10, 10, self.view.width - (verifyImage.width + 2*10 + 10), 44)
        textfield.layer.cornerRadius = 3;
        let cLeftV = UIView(frame: CGRectMake(0, 0, 10, 10))
        cLeftV.backgroundColor = UIColor.clearColor()
        textfield.leftView = cLeftV
        textfield.leftViewMode = .Always
        textfield.layer.masksToBounds = true
        headerView.addSubview(textfield)
        
        uploadBtn.setTitle("压缩上传", forState: UIControlState.Normal)
        uploadBtn.frame = CGRectMake(10, textfield.bottom + 10, self.view.width - 2*10, 44)
        uploadBtn.layer.cornerRadius = 3;
        uploadBtn.layer.masksToBounds = true
        uploadBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        uploadBtn.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        uploadBtn.backgroundColor = UIColor.lightGrayColor()
        uploadBtn.addTarget(self, action: "uploadHar", forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(uploadBtn)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldChange:", name: UITextFieldTextDidChangeNotification, object: nil)
        
        headerView.frame = CGRectMake(0, 64, self.view.width, 44 * 2 + 3 * 10)
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        tableView.tableHeaderView = headerView;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView(frame:CGRectZero)
        self.view.addSubview(tableView)
        
        tableView.registerClass(UploadCell.self, forCellReuseIdentifier: "Cell")
        
        rightBtn.frame = CGRectMake(0, 0, 100, 44)
        rightBtn.contentHorizontalAlignment = .Right
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
        rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
        rightBtn.setTitle("一键清除", forState: UIControlState.Normal)
        rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        let rightItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationItem.title = "上传"
    }
    
    func tap(tipgesture:UITapGestureRecognizer){
        if tipgesture.state == UIGestureRecognizerState.Ended{
            self.loadData()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.textfield.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.center = CGPointMake(verifyImage.width/2, verifyImage.height/2)
        tableView.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64)
    }
    
    func uploadHar() {
        if let code = textfield.text where code.length > 0
        {
            var paths = [String]()
            for item in self.objects
            {
                if item.selected
                {
                    paths.append(item.path)
                }
            }
            
            if paths.count == 0 {
                let alert = UIAlertController(title: nil, message: "是否按默认方式一次最多上传20个文件?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "好", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) in
                    HttpCaptureManager.shareInstance().uploadZip(code, key: self.key ){[weak self] (rs) -> Void in
                        if (rs)
                        {

                        }
                        else{
                            self?.loadData()
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) in
                    
                }))
                self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                HttpCaptureManager.shareInstance().uploadZip(code, key: key ,filepaths:paths){[weak self] (rs) -> Void in
                    if (rs)
                    {
                        
                    }
                    else{
                        self?.loadData()
                    }
                }
            }
            
            self.textfield.resignFirstResponder()
        }
    }
   
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if Int(string) == nil && string.length > 0 && !string.isEngWord(){
            return false
        }
        
        let text = textField.text! + string
        if text.length > 8
        {
            textfield.text = (text as NSString).substringToIndex(8)
            return false
        }
        
        return true
    }
    
    func textFieldChange(notification:NSNotification){
        if let text = textfield.text where Int(text) == nil && text.length > 0 && !text.isEngWord(){
            textfield.text = text.filterNumberLetter()
        }
        if textfield.markedTextRange == nil && textfield.text?.length > 8{
            textfield.text = (textfield.text! as NSString).substringToIndex(8)
        }
        
        if textfield.text?.length > 0 {
            uploadBtn.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        }
        else{
            uploadBtn.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    func loadData() {
        if self.isMemberOfClass(UploadViewController.self) {
            self.loadIndicator(true)
            key = NSString(format: "%.2f", NSDate().timeIntervalSince1970) as String
            
            af.responseSerializer = AFHTTPResponseSerializer()
            //        http://st.360buyimg.com/m/images/index/jd-sprites.png
            af.GET("http://wq.jd.com/deal/hcaptcha/getcode?key=\(key)&scene=2", parameters: nil, success: { (task, obj) in
                
                if let da = obj as? NSData{
                    let img = UIImage(data: da)
                    self.verifyImage.image = img;
                }
                self.loadIndicator(false)
            }) { (task, err) in
                self.loadIndicator(false)
            }
        }
    }
    
    func loadIndicator(bAnimate:Bool) {
        if bAnimate {
            self.activityIndicator.center = CGPointMake(verifyImage.width/2, verifyImage.height/2)
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.startAnimating()
            self.verifyImage.addSubview(self.activityIndicator)
        }
        else{
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.textfield.resignFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? UploadCell
        
        if cell == nil {
            cell = UploadCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        if objects.count > indexPath.row {
            let object = objects[indexPath.row]
            cell?.nameLabel.text = object.fileName
            cell?.sizeLabel.text = object.fileSize
            cell?.dateLabel.text = object.fileDate
            cell?.subselected = object.selected
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
//        if indexPath.row == 0 && indexPath.section == 0 {
            return UITableViewCellEditingStyle.Delete
//        }
        
//        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? UploadCell
        {
            var totalSize:Float = 0;
            for item in self.objects
            {
                if item.selected
                {
                    totalSize += item.fileSize.getBeforeDecimalPointValue()
                }
            }
            if totalSize > 10 * 1024 * 1024 {
                MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("超过最大上传容量哦", delayTime: 3)
                return
            }
            
            let bselect = !cell.subselected
            cell.subselected = bselect
            
            self.objects[indexPath.row].selected = bselect
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    @available(iOS 8.0, *)
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let look = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "查看") { (action, indexpath) in
            self.hiddenDeleteConfirmView()
            self.lookDetail(indexPath)
        }
        look.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "删除") { (action, indexpath) in
            print("delete:")
            self.hiddenDeleteConfirmView()
            self.deleteFile(indexPath)
        }
        
        return [look,delete];
    }
    
    func hiddenDeleteConfirmView() {
        self.tableView.editing = false
    }
    
    func upload() {
        
    }
    
    override func rightButtonClick(item: UIButton) {
        for obj in objects
        {
            FileHelper.FileManager.WQremoveItemAtPath(obj.path, error: nil)
        }
        objects.removeAll()
        self.tableView.reloadData()
    }
    
    func lookDetail(indexPath:NSIndexPath) {
        if objects.count > indexPath.row
        {
            let textvc = SearchViewController()
            
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                if let text = try? String(contentsOfFile: self.objects[indexPath.row].path)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        textvc.text = text;
                    })
                }
            })
            self.navigationController?.pushViewController(textvc, animated: true)
        }
    }
    
    func share(indexPath:NSIndexPath)
    {
        if objects.count > indexPath.row
        {
            MBProgressHUDHelper.sharedMBProgressHUDHelper.showAnimated(true, text: "读取文件内容")
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                var content = ""
                do {
                    try content = NSString(contentsOfFile: self.objects[indexPath.row].path, encoding: NSUTF8StringEncoding) as String
                } catch let err as NSError {
                    DPrintln("err = \(err)")
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var key = NSString(format: "%.1f", NSDate().timeIntervalSince1970) as String
                    key = (self.objects[indexPath.row].path as NSString).getFileNameWithoutSuffix()
                    let path = FileHelper.CacheRootPath.stringByAppendingString("/monitor/share_\(key).txt");
                    do {
                        try content.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
                    } catch let err as NSError {
                        
                    }
                    UIPasteboard.generalPasteboard().string = content
                    
                    MBProgressHUDHelper.sharedMBProgressHUDHelper.hidden(nil, animation: false)
                    
                    let url = NSURL(fileURLWithPath: path)
                    self.documentInteractionController = UIDocumentInteractionController(URL: url)
                    self.documentInteractionController?.delegate = self;
                    self.documentInteractionController?.presentOptionsMenuFromRect(CGRectMake(self.view.width/2 - 100/2, self.view.height/2 - 100/2, 100, 100), inView: self.view, animated: true)
                })
            })
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self;
    }
    
    func deleteFile(indexPath:NSIndexPath) {
        if objects.count > indexPath.row && self.tableView.numberOfRowsInSection(0) > indexPath.row
        {
            FileHelper.FileManager.WQremoveItemAtPath(objects[indexPath.row].path, error: nil)
            objects.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    deinit{
        self.textfield.resignFirstResponder()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
