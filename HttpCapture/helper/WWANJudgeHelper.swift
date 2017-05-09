//
//  WWANJudgeHelper.swift
//  weixindress
//
//  Created by MacDev on 15/7/1.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation
import CoreTelephony

enum  WWANType: Int32 {
    case isNotWWAN = 0,         //当前不是运营商网络或者当前设备没有入网.设备为飞行模式时，telephonyInfo.currentRadioAccessTechnology可能为NIL
    is2G = 1,
    is3G = 2,
    is4G = 3,
    isXG = 4
};

class WWANJudgeHelper {
    static func onGetWWANType() -> WWANType{
        if WXNetworkStatusManager.curStatus == AFNetworkReachabilityStatus.ReachableViaWWAN{
            let telephonyInfo:CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
            if let techMode = telephonyInfo.currentRadioAccessTechnology{
                return self.onGetWWANTypeWithAccessTechnology(techMode)
            }
            else{
                return WWANType.isNotWWAN
            }
        }
        else{
            return WWANType.isNotWWAN
        }
    }
    
    static func onGetWWANTypeWithAccessTechnology(radioAccessTechnology:String!) -> WWANType{
        //2g
        if radioAccessTechnology == CTRadioAccessTechnologyGPRS {
            return WWANType.is2G;
        }
        //2g
        else if radioAccessTechnology == CTRadioAccessTechnologyEdge {
            return WWANType.is2G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyWCDMA {
            return WWANType.is3G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyHSDPA {
            return WWANType.is3G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyHSUPA {
            return WWANType.is3G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyCDMA1x {
            return WWANType.is3G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyCDMAEVDORev0 {
            return WWANType.is3G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyCDMAEVDORevA {
            return WWANType.is3G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyCDMAEVDORevB {
            return WWANType.is3G;
        }
        //3g
        else if radioAccessTechnology == CTRadioAccessTechnologyeHRPD {
            return WWANType.is3G;
        }
        //准4g，可看作是4g中的一种
        else if radioAccessTechnology == CTRadioAccessTechnologyLTE {
            return WWANType.is4G;
        }
        
        return WWANType.isXG;
    }

    
}

















