//
//  SearchViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/30.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class SearchViewController: TextViewController,UISearchBarDelegate {
    var searchBar = UISearchBar()
    var showSegment = false;
    
    convenience init(showSegment:Bool){
        self.init()
        self.showSegment = showSegment
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar(frame: CGRectMake(0, 64, self.view.frame.size.width, 44))
        let img:UIImage = UIImage.imageWithColor(UIColor.fromRGBA(0xf2f2f2ff), size: CGSizeMake(WXDevice.width, 64))
        searchBar.setBackgroundImage(img, forBarPosition: .Any, barMetrics: UIBarMetrics.Default)
        searchBar.barTintColor = UIColor.fromRGBA(0xf2f2f2ff)
        searchBar.delegate = self
        searchBar.placeholder = "搜索"
        self.view.addSubview(searchBar)
        
        if !showSegment {
            segment.removeAllSegments()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segment.center = CGPointMake(self.view.width/2, 20 + 22)
        textView.frame = CGRectMake(10, 64 + 10 + searchBar.height, self.view.width - 10*2, self.view.height - 64 - 10*2 - searchBar.height)
    }

    func scrollToTop(){
        self.textView.scrollRectToVisible(CGRectMake(0, 0, self.view.width, 10), animated: true)
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
       
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: false)
        self.searchBar.resignFirstResponder()
        
        let text = self.textView.attributedText.string;
        let attrText = NSMutableAttributedString(string:text)
        let range = attrText.getFirstRange(self.searchBar.text)
        DPrintln("range =\(range)")
        if range.length > 0
        {
            self.textView.scrollRangeToVisible(range)
        }
        
        MBProgressHUDHelper.sharedMBProgressHUDHelper.showAnimated(true, text: "正在搜索")
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            attrText.highlightString(self.searchBar.text?.lowercaseString, withColour: UIColor.CustomRed())
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                MBProgressHUDHelper.sharedMBProgressHUDHelper.hidden(nil, animation: true)
                self.textView.attributedText = attrText
            })
        })
    }
    
    deinit
    {
        self.searchBar.resignFirstResponder()
    }
}
