//
//  AppConfiguration.swift
//  weixindress
//
//  Created by tianjie on 2/16/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation

// 该枚举用于消息推送时，判断应用是否运行状态
enum AppState {
    case Running        // 程序正在运行
    case unRunning      // 程序没有运行状态
}

public class AppConfiguration {
    
    static let Brand_New_Style:Bool = true
//    static let httpVersion = false
    
    struct Defaults {
        static let xgAppID:UInt32 = 2200095512   //信鸽appid
        static let xgAppKey = "I362I2YCB9BJ"     //信鸽appkey
        
        static let channel = "appstore" //渠道号
        static let RDMChannel = "RDMChannel"
        static let DebugChannel = "DebugChannel"
        
        static let Official_XY_Channel = "Official_XY_Channel"              //XY苹果助手
        static let Official_TBT_Channel = "Official_TBT_Channel"            //同步推苹果助手
        static let Official_PP_Channel = "Official_PP_Channel"              //PP助手
        static let Official_AS_Channel = "Official_AS_Channel"              //爱思助手
        static let Official_iTools_Channel = "Official_iTools_Channel"      //iTools助手
        static let Official_91market_Channel = "Official_91market_Channel"  //91助手
        static let Official_kuaiyong_Channel = "Official_kuaiyong_Channel"  //快用
        
        static let UMengID = "55bb2c8267e58e30050007e8"         //友盟APP ID
        static let firstLaunchKey = "AppConfiguration.Defaults.firstLaunchKey"
        static let userDefaultCommonKey = "AppConfiguration.Defaults.userDefaultCommonKey"
        static let apnsToken = "AppConfiguration.Defaults.apnsToken"
        
        static let isFirstTime = "AppConfiguration.Defaults.AppFirstShow"
        
        static let isCloseNotification = "isCloseNotification" // 设置中是否开启消息提醒
        static let isCloseCache = "isCloseCache" // 设置中是否开启离线缓存，方便调试
        static let appLaunchCountKey = "AppLaunchCount" //应用启动次数
        static let orderH5Str = "OrderH5Str" // 强制h5结算
        static let gl_orderH5Str = "OrderH5StrGoodLocal" // 强制h5展示商详
        static let sl_orderH5Str = "sl_orderH5Str" // 强制h5展示搜索
        static let rn_H5Str = "rn_H5Str" // 强制将react native改为h5展示个人中心
        static let openFilterFunction = "openFilterFunction" //展示筛选
        static let AppSlogan = "小衣橱，大时尚"
        
        static let UrlWhiteListKey = "config.webview.domain.whitelist"
        
        static let XML_iOS_LastupTime  = "iOS.lastup.time" + WXDevice.bundleVersion
        static let XML_H5_LastupTime  = "H5.lastup.time" + WXDevice.bundleVersion
        static let XML_property_LastupTime  = "property.lastup.time" + WXDevice.bundleVersion
        static let lastWid = "lastWid"   //信鸽appid
        
        static let HotTabKey    = "Tab_HotTabKey"
        static let NewTabKey    = "Tab_NewTabKey"
        static let staticLocationKey = "jdUserAddress"                //京东用户配送地址
        static let FactLastVersionKey = "FactLastVersionKey"
        
        static let lastVersionKey = "lastVersionKey"
        
        static let AppStyle = "AppConfiguration.Appeareance.Style"
        static let AppStyleBI = "AppConfiguration.Appeareance.StyleBI"
        static let ShowAppStyleTip = "AppConfiguration.Appeareance.ShowAppStyleTip"

        static let AppLaunchTime = "AppLaunchTime"
        static let AppCrashTime = "AppCrashTime"
        static let AppUseEncodeProductDecorateKey = "AppUseEncodeProductDecorateKey"
        
        static let addProductInCollocationEditSceneKey = "addProductInCollocationEditSceneKey"
        static let addProductBtnSceneKey = "addProductBtnSceneKey"
        static let collocationAnimationSceneKey = "collocationAnimationSceneKey"
        static let publishCollocationSceneKey = "publishCollocationSceneKey"
        
        static let scheme = "jdhttpmonitor"
    }
    
    struct NotifyNames {
        static let propertiesConfigUpdate = "PropertiesConfigUpdate"
        static let PrivateDapeiUpdateWhenAdd = "PrivateDapeiUpdateWhenAdd"
        static let PrivateDapeiUpdateWhenDelete = "PrivateDapeiUpdateWhenDelete"
        static let decorateListUpdate = "decorateListUpdate"
        static let productListUpdate = "productListUpdate"
        static let loveDataUpdate = "loveDataUpdate"
        static let productCategoryUpdate = "productCategoryUpdate"
        static let provinceCityCountyDataUpdate = "provinceCityCountyDicUpdate" //省市县乡、偏远地区、偏远非例外地区数据更新
        static let productPickerShowFinish = "productPickerShowFinish"
        static let searchLocalFilterConditionChange = "searchLocalFilterConditionChange"
        static let loadPromoImageFinishNotification = "loadPromoImageFinishNotification"
        static let refreshFileNotification = "refreshFileNotification"
//        static let refreshPageRequest = "refreshPageRequest"
        
    }
    
    struct Urls {
        static var guideUrl = "http://h5.darkal.cn/har/guide/widget.basic.html"
        static var helpUrl = "http://h5.darkal.cn/har/guide_ios/widget.guide.html"
        static var homeUrl = "http://wqs.jd.com"
//        static var monitorUrl = "http://wqs.jd.com/app/brand/style1/female.shtml?jzycwt=1"
//        static var monitorUrl = "https://wqs.jd.com/app/brand/style1/brand.shtml"
//        static var monitorUrl =  "https://www.jd.com"
//        static var monitorUrl =  "http://www.tmall.com"
//        static var monitorUrl =  "http://192.168.1.101"             //mac的ip地址
//        static var monitorUrl =  "http://10.14.222.47"                //mac的ip地址
//        static var monitorUrl =  "https://www.baidu.com"
//        static var monitorUrl = "http://union.m.jd.com/click/go.action?to=%2F%2Fm.jd.com%2F&type=1&unionId=pcmtiaozhuan&subunionId=pcmtiaozhuan&keyword="
    }
    
    
    // 本地缓存
    struct CacheCommon
    {
        // 缓存主文件夹
        static let CACHE_FORDER_NAME = "cache"
        // 正在升级的目录
        static let UPDATING_FORDER_NAME = "updating"
        // 正在使用的目录
        static let LOCAL_FORDER_NAME = "local"
        // zip包目录
        static let ZIP_FORDER_NAME = "zip"
        // 衣物图片目录
        static let CLOTHES_PIC_FORDER_NAME = "clothes_pic"
        // 搭配图片目录
        static let COLLOCATIONS_FORDER_NAME = "collocations_pic"
        // 在线搭配目录
        static let ONLINE_COLLOCATIONS_FORDER_NAME = "online_collocations_pic"
        // 缓存主文件夹
        static let LOCAL_304 = "304"
        // 下载最大尝试次数
        static let MAX_MODULE_RETRY:Int = 5
        // 升级服务 参见：http://cf.jd.com/pages/viewpage.action?pageId=46347244
//        static let UPGRADE_METADATA_URL = "http://wq.jd.com/mcoss/appup/upgrade"
        static let UPGRADE_METADATA_URL = "http://wq.jd.com/mcoss/appup/u2"
//        static let UPGRADE_METADATA_URL = "http://appup.wq.jd.com/mcoss/appup/u2"   ////:80/mcoss/appup/u2"
        
        static var DecorateListDir = "DecorateListDir"
        
        static var GoodLocalDir = "GoodLocal"
        
        static var DecorateListUrlDirectoryPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.DecorateListDir)");
        
        static var DecorateListUrlDicPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.DecorateListDir)/DecorateList.file");
        
        static var FilterFileDir = "FilterFileDir"
        
        static var FilterFile_DirectoryPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.FilterFileDir)");
        
        static var Nv_ProductDataDir = "Nv_ProductDataDir"
        
        static var Nv_ProductDataUrlDirectoryPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.Nv_ProductDataDir)");
        
        static var Nv_ProductDataUrlDicPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.Nv_ProductDataDir)/Nv_ProductDataDir.file");
        
        static var Love_ProductDataDir = "Love_ProductDataDir"
        
        static var Love_ProductDataUrlDirectoryPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.Love_ProductDataDir)");
        
        static var Love_ProductDataUrlDicPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.Love_ProductDataDir)/Love_ProductDataDir.file");
        
        static var Nan_ProductDataDir = "Nan_ProductDataDir"
        
        static var Nan_ProductDataUrlDirectoryPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.Nan_ProductDataDir)");
        
        static var Nan_ProductDataUrlDicPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.Nan_ProductDataDir)/Nan_ProductDataDir.file");
        
        static var ProductCategoryDir = "ProductCategoryDir"
        
        static var ProductCategoryUrlDirectoryPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.ProductCategoryDir)");
        
        static var ProductCategoryUrlDirPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.ProductCategoryDir)/ProductCategoryDir.file");
        
        static var PDLovedItemsPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.ProductCategoryDir)/lovedItemIDs");
        
        static var cacheUrlDicPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/CacheUrlDict.file");
        // 更新中的upgrade-metadata.xml
        static let updatingXmlPath:NSURL = FileHelper.CacheRoot!.URLByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/upgrade.xml")
        
        static var ProvinceCityCountyDirectoryPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.GoodLocalDir)");
        
        static var ProvinceCityCountyPlistPath = FileHelper.CacheRootPath.stringByAppendingPathComponent("\(CacheCommon.CACHE_FORDER_NAME)/\(CacheCommon.GoodLocalDir)/ProvinceCityCounty.plist");
        
    }
    
    public class var sharedConfiguration: AppConfiguration {
        struct Singleton {
            static let sharedAppConfiguration = AppConfiguration()
        }
        
        return Singleton.sharedAppConfiguration
    }
    
    public func runHandlerOnFirstLaunch(firstLaunchHandler: Void -> Void) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let defaultOptions: [String: AnyObject] = [
            Defaults.firstLaunchKey: true
        ]
        
        defaults.registerDefaults(defaultOptions)
        
        if defaults.boolForKey(Defaults.firstLaunchKey) {
            defaults.setBool(false, forKey: Defaults.firstLaunchKey)
            
            firstLaunchHandler()
        }
    }
}

struct ActivityUserDefaultStruct {
    static let currentActivityTime = "currentActivityTime"
    static let nextActivityTime = "nextActivityTime"
    static let activityTime = "ActivityTime"
    static let tabbarActiveTime = "tabbarActiveTime"
    
    static let TabbarActiveConfigure = "tabbarActiveConfigure"

}


