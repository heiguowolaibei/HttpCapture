//
//  NSUserDefaults+WXSQUserDefaults.swift
//  weixindress
//
//  Created by tianjie on 3/18/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    //    class func getObjectFromNSUserDefaultsWithKey(key: String) -> AnyObject? {
    //        var object: AnyObject?
    //        let defaults = NSUserDefaults.standardUserDefaults()
    //        if let dict = defaults.dictionaryForKey(AppConfiguration.Defaults.userDefaultCommonKey) {
    //            object = dict[key]
    //        }
    //        return object
    //    }
    //
    //    class func setObjectToNSUserDefaults(object: AnyObject!, withKey key: String) {
    //        let defaults = NSUserDefaults.standardUserDefaults()
    //        if var dict = defaults.dictionaryForKey(AppConfiguration.Defaults.userDefaultCommonKey) {
    //            dict[key] = object
    //            defaults.setObject(dict, forKey: AppConfiguration.Defaults.userDefaultCommonKey)
    //            defaults.synchronize()
    //        }
    //    }
    
//    class func removeObjectFromNSUserDefaultsWithKey(key: String) {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if var dict = defaults.dictionaryForKey(AppConfiguration.Defaults.userDefaultCommonKey) {
//            dict[key] = nil
//            defaults.setObject(dict, forKey: AppConfiguration.Defaults.userDefaultCommonKey)
//            defaults.synchronize()
//        }
//    }
    
    class func setObjectToUserDefaults(object:NSObject?, key:String) -> Bool {
        if object == nil {
            return false
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(object!, forKey: key)
        return defaults.synchronize()
    }
    
    class func getObjectFromUserDefaults(key:String) -> AnyObject?{
        var object: AnyObject?
        let defaults = NSUserDefaults.standardUserDefaults()
        object = defaults.objectForKey(key)
        return object
    }
    
    class func removeObjectFromUserDefaultsWithKey(key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(key)
        defaults.synchronize()
    }
    
}