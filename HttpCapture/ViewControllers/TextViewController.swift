//
//  TextViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/25.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit
import Foundation

class TextViewController: CaptureBaseViewController,UITextViewDelegate {
    var textView = UITextView()
    var segment = UISegmentedControl()
    var text = ""
        {
        didSet{
            if text.dataUsingEncoding(NSUTF8StringEncoding)?.length > 20 * 1024 * 1024 {
                MBProgressHUDHelper.sharedMBProgressHUDHelper.showText("文件内容过大", delayTime: 3)
            }
            else{
                segment.hidden = false
                textView.attributedText = NSAttributedString(string:text);
            }
        }
    }
    var img:UIImage?
    {
        didSet{
            self.configImg()
        }
    }
    var entry:Entry?
    var sTitle:String?
    var bNeedRightBtn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets = false
        textView.textContainerInset = UIEdgeInsetsMake(13, 7, 5, 0)
        textView.textColor = UIColor.fromRGBA(0x333333ff)
        textView.delegate = self;
        textView.font = UIFont.systemFontOfSize(15)
        textView.layer.borderWidth = 1/WXDevice.scale;
        textView.layer.borderColor = UIColor.fromRGB(0x222222).CGColor
        self.view.addSubview(textView)
        
        segment.frame = CGRectMake(0, 0, 120, 34)
        segment.insertSegmentWithTitle("原文查看", atIndex: 0, animated: false)
        
        if entry?.response.content.mimeType == "application/json" || entry?.response.content.mimeType == "text/javascript" ||
        entry?.response.content.mimeType == "text/json" || entry?.response.content.mimeType == "application/javascript" || entry?.response.content.mimeType == "text/html"
        {
            segment.insertSegmentWithTitle("json查看", atIndex: 1, animated: false)
        }
        else if entry?.response.content.mimeType == "text/html"
        {
            segment.insertSegmentWithTitle("样式查看", atIndex: 2, animated: false)
        }
        else{
            segment.removeAllSegments()
        }
        segment.tintColor = UIColor.fromRGB(0xe11644)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: "segchange", forControlEvents: UIControlEvents.ValueChanged)
        segment.hidden=text.length == 0
        segment.center = CGPointMake(self.navigationBar.width/2, self.navigationBar.height/2)
        
        if let stitle = sTitle
        {
            self.navigationItem.title = stitle
        }
        else{
            self.navigationItem.titleView = segment
        }
        
        if bNeedRightBtn {
            rightBtn.frame = CGRectMake(0, 0, 44, 44)
            rightBtn.contentHorizontalAlignment = .Right
            rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
            rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
            rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
            rightBtn.setTitleColor(UIColor.fromRGBA(0x666666ff), forState: UIControlState.Normal)
            rightBtn.contentMode = UIViewContentMode.ScaleAspectFit;
            rightBtn.setImage(CommonImageCache.getImage(named: "清空"), forState: UIControlState.Normal)
            rightBtn.addTarget(self, action: "rightButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let rightItem = UIBarButtonItem(customView: rightBtn)
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    func changeSelect() {
//        let ar = segment.subviews
//        
//        for (index,view) in ar.enumerate()
//        {
//            if let control = view as? UIControl
//            {
//                if control.selected == true
//                {
//                    control.tintColor = UIColor.fromRGB(0xe11644)
//                }
//                else{
//                    control.tintColor = UIColor.fromRGB(0xeeeeee)
//                }
//            }
//        }
    }
    
    override func rightButtonClick(btn:UIButton) {
        self.text = ""
        
    }
    
    func segchange() {
        if segment.selectedSegmentIndex == 0
        {
            textView.attributedText = NSAttributedString(string: self.text)
        }
        if segment.selectedSegmentIndex == 1
        {
            var isJson = false
            if let da = text.dataUsingEncoding(NSUTF8StringEncoding)
            {
                if let json = JsonParser.jsonpParse(da)
                {
                    if let dic = json as? NSDictionary
                    {
                        isJson = true
                        textView.attributedText = NSAttributedString(string: dic.description)
                    }
                    else if let ar = json as? NSArray
                    {
                        isJson = true
                        textView.attributedText = NSAttributedString(string: ar.description)
                    }
                }
            }
            
            if !isJson {
                textView.attributedText = NSAttributedString(string: "")
            }
            
        }
        if segment.selectedSegmentIndex == 2
        {
            if let da = self.text.dataUsingEncoding(NSUTF8StringEncoding)
            {
                let atrString = try? NSAttributedString(data: da, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType ], documentAttributes: nil)
                self.textView.attributedText = atrString;
            }
        }
    }
    
    func configImg()  {
        if let image = img {
            segment.hidden = true
            let attributedString = NSMutableAttributedString(string: " \r\n图片宽高：\(image.size.width)*\(image.size.height)")
            let textAttachment = NSTextAttachment();
            textAttachment.image = image;
            
            if image.size.width > self.textView.width && image.CGImage != nil {
                let scale = image.size.width/(self.textView.width - 20)
                textAttachment.image = UIImage(CGImage: image.CGImage!, scale: scale, orientation: UIImageOrientation.Up)
            }
            
            let ttrStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharactersInRange(NSMakeRange(0, 1), withAttributedString: ttrStringWithImage)
            textView.attributedText = attributedString;
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true;
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return false
    }
    
    override func leftButtonClick(item: UIButton) {
        self.textView.resignFirstResponder()
        super.leftButtonClick(item)
    }
    
    override func useDefaultBackButton() -> Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segment.frame = CGRectMake(0, 0, segment.width, segment.height)
        textView.frame = CGRectMake(10, 64 + 10, self.view.width - 10*2, self.view.height - 64 - 10*2)
    }
}
