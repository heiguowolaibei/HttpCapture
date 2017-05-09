//
//  ShareViewController.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/9/8.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit

class ShareViewController: UploadViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "点击分享"
        tableView.tableHeaderView = UIView();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(Float(NSEC_PER_SEC) * 2))
//        dispatch_after(popTime, dispatch_get_main_queue(), {
//            () ->Void in
//            let path = NSIndexPath(forRow: 0, inSection: 0)
////            self.tableView.cellForRowAtIndexPath(path)?.setEditing(true, animated: true)
//            if let vi = self.tableView.cellForRowAtIndexPath(path)?.contentView
//            {
//                var frame = vi.frame
//                frame.origin.x = -120;
//                vi.frame = frame
//                
////                self.setscrollview(self.tableView.cellForRowAtIndexPath(path)!)
//                let ce = self.tableView.cellForRowAtIndexPath(path) as? UploadCell
//                if let c = ce?.subvi(ce!)
//                {
//                    var frame = c.frame
//                    frame.origin.x = -120;
//                    c.frame = frame
//                }
//            }
//        })
        
    }
    
    func setscrollview(cell:UITableViewCell)
    {
        for item in cell.subviews
        {
            if let scrollView = item as? UIScrollView{
                scrollView.backgroundColor = UIColor.fromRGB(0x333333)
                break;
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath);
        (cell as? UploadCell)?.showSelect = false
        return cell;
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
//    editingStyleForRowAtIndexPath
//    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
//    {
//        if tableView.editing {
//            return UITableViewCellEditingStyle.Delete
//        }
//        
//        return UITableViewCellEditingStyle.None
//    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.cellForRowAtIndexPath(indexPath)
        
        self.share(indexPath)
    }
    
    @available(iOS 8.0, *)
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let share = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "分享") { (action, indexpath) in
            print("share")
            self.hiddenDeleteConfirmView()
            self.share(indexPath)
        }
        share.backgroundColor = UIColor(red: 0.598, green: 0.551, blue: 0.3922, alpha: 1.0);
        
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
        return [share,look,delete];
    }
    
    
}
