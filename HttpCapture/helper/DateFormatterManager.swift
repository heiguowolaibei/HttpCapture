//
//  DateFormatterManager.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/17.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import UIKit
import Foundation

@objc class DateFormatterManager:NSObject {
    
    var YMD_HMS_date_formatter:NSDateFormatter?     // YYYY-MM-dd hh:mm:ss
    var YMD_HM_date_formatter:NSDateFormatter?      // YYYY-MM-dd hh:mm
    var YMD_date_formatter:NSDateFormatter?         // YYYY-MM-dd
    var YMD_date_formatter_2:NSDateFormatter?       // YYYY年MM月dd日 HH:mm
    var MD_HM_date_formatter:NSDateFormatter?       // HH:mm:ss
    var Today_HM_date_formatter:NSDateFormatter?    // 今天 hh:mm
    var var_date_formatter:NSDateFormatter?         // var格式
    private var mutex = pthread_mutex_t()
    
    var queue = dispatch_queue_create("dateformatter_queue", DISPATCH_QUEUE_SERIAL);
    
    class var sharedInstance:DateFormatterManager {
        struct Static {
            static let instance : DateFormatterManager = DateFormatterManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        pthread_mutex_init(&mutex, nil)
        
        dispatch_async(queue) {
            self.YMD_HMS_date_formatter = NSDateFormatter()
            self.YMD_HMS_date_formatter?.dateFormat = "YYYY-MM-dd HH:mm:ss"
            
            self.YMD_HM_date_formatter = NSDateFormatter()
            self.YMD_HM_date_formatter?.dateFormat = "YYYY-MM-dd HH:mm"
            
            self.YMD_date_formatter = NSDateFormatter()
            self.YMD_date_formatter?.dateFormat = "YYYY-MM-dd"
            
            self.YMD_date_formatter_2 = NSDateFormatter()
            self.YMD_date_formatter_2?.dateFormat = "YYYY年MM月dd日 HH:mm"
            
            self.MD_HM_date_formatter = NSDateFormatter()
            self.MD_HM_date_formatter?.dateFormat = "HH:mm:ss"
            
            self.Today_HM_date_formatter = NSDateFormatter()
            self.Today_HM_date_formatter?.dateFormat = "今天 HH:mm"

            self.var_date_formatter = NSDateFormatter()
            self.var_date_formatter?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        }
    }
    
    @objc func parseStyleSync(v:Int,date:NSDate) -> String {
        var sdate = ""
        
        pthread_mutex_lock(&self.mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        switch v {
            case 0:
                if let s = self.YMD_HMS_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 1:
                if let s = self.YMD_HM_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 2:
                if let s = self.YMD_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 3:
                if let s = self.YMD_date_formatter_2?.stringFromDate(date)
                {
                    sdate = s
                }
            case 4:
                if let s = self.MD_HM_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 5:
                if let s = self.Today_HM_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 6:
                if let s = self.var_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            default:
                break
        }
        
        return sdate
    }
    
    func parseStyle(v:Int,date:NSDate,block:(s:String)->Void) {
        dispatch_async(queue) {
            pthread_mutex_lock(&self.mutex)
                
            var sdate = ""

            switch v {
            case 0:
                if let s = self.YMD_HMS_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 1:
                if let s = self.YMD_HM_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 2:
                if let s = self.YMD_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 3:
                if let s = self.YMD_date_formatter_2?.stringFromDate(date)
                {
                    sdate = s
                }
            case 4:
                if let s = self.MD_HM_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 5:
                if let s = self.Today_HM_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            case 6:
                if let s = self.var_date_formatter?.stringFromDate(date)
                {
                    sdate = s
                }
            default:
                break
            }
            
            pthread_mutex_unlock(&self.mutex)
            
            dispatch_async(dispatch_get_main_queue(), {
                block(s:sdate)
            })
        }
    }
    
    deinit{
        pthread_mutex_destroy(&mutex)
    }
}