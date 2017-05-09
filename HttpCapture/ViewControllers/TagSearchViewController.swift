
//
//  BrandTagSearchViewController.swift
//  weixindress
//
//  Created by WeiHu on 16/8/11.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

import UIKit

enum SearchBtnType {
    case Host
    case Ip
    case HostType
}

//class HostTypeModel: NSObject,NSCoding,NSCopying{
//    var id: String = ""
//    var name: String = ""
//    
//    func encodeWithCoder(_aCoder: NSCoder) {
//        _aCoder.encodeObject(id,forKey:"id")
//        _aCoder.encodeObject(name,forKey:"name")
//    }
//    
//    override init() {
//        super.init()
//    }
//    
//    required convenience init(coder aDecoder: NSCoder) {
//        self.init()
//        
//        if let id_ = aDecoder.decodeObjectForKey("id") as? String{
//            self.id = id_
//        }
//        if let name_ = aDecoder.decodeObjectForKey("name") as? String{
//            self.name = name_
//        }
//    }
//    
//    func copyWithZone(zone: NSZone) -> AnyObject {
//        
//        let model = HostTypeModel()
//        model.id = self.id
//        model.name = self.name
//        
//        return model
//    }
//    
//}

typealias SearchBtnBlock = (str: String)->Void

class TagSearchViewController: CaptureBaseViewController {
    /// private
    private var _searchTextField: UITextField!
    private var _tableView: UITableView!
    var dataArray: [HostModel]? {
        didSet{
            tableView.reloadData()
        }
    }
    
    private var textRange:UITextRange?
    var originStr:String?
    /// public
    var type: SearchBtnType = .Host
    var searchBlock: SearchBtnBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.searchTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.searchTextField.becomeFirstResponder()
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: searchTextField)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension TagSearchViewController{
    private func xnStringAllIsEmpty(string: String) -> Bool {
        let set = NSCharacterSet .whitespaceAndNewlineCharacterSet();
        let trimedString = string.stringByTrimmingCharactersInSet(set);
        if trimedString.characters.count == 0 {
            //print("全是空格");
            return true;
        }else {
            
            return false;
        }
    }
}
extension TagSearchViewController{
    private func configureViews(){
        self.view.backgroundColor = UIColor.whiteColor()
        self.leftBtn.hidden = true
      
        self.rightBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        self.rightBtn.setTitleColor(UIColor.fromRGBA(0x333333ff), forState: .Normal)
        self.rightBtn.setTitle("取消", forState: .Normal)
        
        self.navigationBar.addSubview(searchTextField)
        self.view.addSubview(tableView)
        self.consraintsForSubViews();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TagSearchViewController.textFiledEditChanged(_:)), name: UITextFieldTextDidChangeNotification, object: searchTextField)
    }
    // MARK: - views actions
    override func rightButtonClick(item: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    // MARK: - getter and setter
    
    private var tableView: UITableView {
        get{
            if _tableView == nil{
                _tableView = UITableView()
                _tableView.translatesAutoresizingMaskIntoConstraints = false
                _tableView.backgroundColor = UIColor.clearColor()
                _tableView.dataSource = self
                _tableView.delegate = self
                _tableView.separatorColor = UIColor.blackColor()
                _tableView.separatorStyle = .None
                _tableView.separatorInset = UIEdgeInsetsZero
                _tableView.showsVerticalScrollIndicator = false
                _tableView.showsHorizontalScrollIndicator = false
                _tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCellID")
            }
            return _tableView
            
        }
        set{
            _tableView = newValue
        }
    }
    
    private var searchTextField: UITextField {
        get{
            if _searchTextField == nil{
                _searchTextField = UITextField()
                
                if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0{
                    _searchTextField.translatesAutoresizingMaskIntoConstraints =  true
                    _searchTextField.frame = CGRectMake(10, self.navigationBar.height - 7 - 30, self.navigationBar.width - 55, 30)
                }else{
                    _searchTextField.translatesAutoresizingMaskIntoConstraints =  false
                    _searchTextField.frame = CGRect.zero
                }
                _searchTextField.backgroundColor = UIColor.colorWithRGB(red: 242, green: 242, blue: 242)
                _searchTextField.layer.cornerRadius = 15
                _searchTextField.layer.masksToBounds = true
                _searchTextField.becomeFirstResponder()
                _searchTextField.font = UIFont.systemFontOfSize(14)
                _searchTextField.text = ""
                _searchTextField.clearButtonMode = .Always
                _searchTextField.delegate = self
                _searchTextField.returnKeyType = .Done
                if let text = self.originStr
                {
                    _searchTextField.text = text.trimSpaceNewLine()
                }
                
                switch self.type {
                    case .Host:
                        _searchTextField.placeholder = " 请输入域名"
                    case .Ip:
                        _searchTextField.placeholder = " 请输入IP"
                    default:
                        break
                }
                let leftView = UIView()
                leftView.frame = CGRectMake(0, 0, 30, 15)
                let imageView = UIImageView(frame: CGRectMake(10, 0, 15, 15))
                imageView.image = UIImage(named: "brand_tag_search")
                leftView.addSubview(imageView)
                
                _searchTextField.leftView = leftView
                _searchTextField.leftViewMode = .Always
            }
            return _searchTextField
        }
        set{
            _searchTextField = newValue
        }
    }
    

    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": tableView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-44-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": tableView]))
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0{
            self.navigationBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[view]-55-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": searchTextField]));
            self.navigationBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==30)]-7-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": searchTextField]))
        }
    }
}

extension TagSearchViewController: UITextFieldDelegate{
    
    func textFiledEditChanged(nofication: NSNotification) {
        if let textfield = nofication.object as? UITextField where textfield.text != nil && textfield.markedTextRange == nil && self.type != .HostType
        {
            if let text = textfield.text where Int(text) == nil && text.length > 0{
                textfield.text = text.filterNumberLetterAndPoint()
            }
            var maxLength: Int = 0
            switch self.type {
            case .Host:
                maxLength = 30
            case .Ip:
                maxLength = 15
            default:
                break
            }
            if textfield.text?.length > maxLength
            {
                textfield.text = (textfield.text! as NSString).substringToIndex(maxLength)
            }
            
            if self.type == .Ip
            {
                let ar = textfield.text!.componentsSeparatedByString(".")
                if let last = ar.last where (last.length > 3 || Int(last) > 255){
                    textfield.text = (textfield.text! as NSString).substringToIndex(textfield.text!.length - 1)
                }
            }
            
            textfield.text = textfield.text!.trimSpaceNewLine()
            
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            cell?.textLabel?.text = "点击添加:\(textfield.text!)"
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        if self.type == .HostType {
            return true
        }
        if textField.text == nil {
            return false
        }
        let text = textField.text! + string
        
        if self.type == .Host {
            if Int(string) == nil && string.length > 0 && !string.isEngWord() && string != "."{
                return false
            }
        }
        if self.type == .Ip {
            if Int(string) == nil && string.length > 0 && string != "."
            {
                return false
            }
            let ar = text.componentsSeparatedByString(".")
            if let last = ar.last where (last.length > 3 || Int(last) > 255){
                return false
            }
        }
        if textField.text?.length > 0 {
            let char = (textField.text! as NSString).substringWithRange(NSMakeRange(textField.text!.length - 1, 1))
            if char == "." && string == "."
            {
                return false
            }
        }
        
        var maxLength: Int = 0
        switch self.type {
        case .Host:
            maxLength = 30
        case .Ip:
            maxLength = 15
        default:
            break
        }
        if text.length > maxLength
        {
            MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("不能超过\(maxLength)个字符哦")
            textField.text = (text as NSString).substringToIndex(maxLength)
            return false
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool{
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.navigationController?.popViewControllerAnimated(true)
        if let block = searchBlock
        {
            let contentStr: String = textField.text ?? ""
            block(str: contentStr)
        }
        return true
    }

}
extension TagSearchViewController: UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let dataArray_ = dataArray {
            return 1 + dataArray_.count
        }
        
        return 1
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCellID")
        cell?.textLabel?.font = UIFont.systemFontOfSize(14)
        
        switch indexPath.row {
            case 0:
                cell?.imageView?.image = UIImage(named: "add_brand_tag")
                cell?.textLabel?.text = "点击添加:\(_searchTextField.text ?? "")"
                cell?.textLabel?.textColor = UIColor.fromRGB(0x999999)
            default:
                if let dataArray_ = dataArray{
                    let m = dataArray_[indexPath.row - 1]
                    cell?.imageView?.image = nil
                    cell?.textLabel?.text = "\(m.name)"
                }
        }
        
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var text = ""
        if indexPath.row == 0
        {
            text = searchTextField.text ?? ""
        }
        else
        {
            if let dataArray_ = dataArray{
                let model = dataArray_[indexPath.row - 1]
                text =  model.name
            }
        }

        if let block = searchBlock{
            block(str: text)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchTextField.resignFirstResponder()
    }
}