//
//  NSFileManager+ErrorHandler.swift
//  weixindress
//
//  Created by duyongchao on 15/9/18.
//  Copyright © 2015年 www.jd.com. All rights reserved.
//

import UIKit

extension NSFileManager {
    func WQcopyItemAtURL(srcURL: NSURL, toURL dstURL: NSURL, error:NSErrorPointer) {
        do{
            try self.copyItemAtURL(srcURL, toURL: dstURL)
        }
        catch let error1 as NSError{
            if error != nil {
                error.memory = error1
            }
        }
    }
    func WQremoveItemAtURL(URL: NSURL,error:NSErrorPointer) {
        do{
            try self.removeItemAtURL(URL)
        }
        catch let err as NSError {
            if error != nil {
                error.memory = err
            }
        }
    }
    func WQremoveItemAtPath(path: String,error:NSErrorPointer) {
        do {
            try self.removeItemAtPath(path)
        } catch let err as NSError {
            if error != nil {
                error.memory = err
            }
        }
    }
    func WQmoveItemAtURL(srcURL: NSURL, toURL dstURL:NSURL ,error:NSErrorPointer) {
        do {
            try self.moveItemAtURL(srcURL, toURL: dstURL)
        } catch let err as NSError {
            if error != nil {
                error.memory = err
            }
        }
    }
    func WQattributesOfItemAtPath(path: String,error:NSErrorPointer) -> [String : AnyObject]?{
        var re = [String : AnyObject]()
        do {
            re = try self.attributesOfItemAtPath(path)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
            return nil
        }
        return re
    }
    func WQURLForDirectory(directory: NSSearchPathDirectory, inDomain domain: NSSearchPathDomainMask, appropriateForURL url: NSURL?, create shouldCreate: Bool,error:NSErrorPointer) -> NSURL? {
        var re = NSURL()
        do {
            re = try self.URLForDirectory(directory, inDomain: domain, appropriateForURL: url, create: shouldCreate)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
            return nil
        }
        return re
    }
    func WQcreateDirectoryAtURL(url: NSURL, withIntermediateDirectories createIntermediates: Bool, attributes: [String : AnyObject]?, error:NSErrorPointer) {
        do {
            try self.createDirectoryAtURL(url, withIntermediateDirectories: createIntermediates, attributes: attributes)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
        }
    }
    func WQcreateDirectoryAtPath(path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [String : AnyObject]?, error:NSErrorPointer) {
        do {
            try self.createDirectoryAtPath(path, withIntermediateDirectories: createIntermediates, attributes: attributes)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
        }
    }
    func WQattributesOfFileSystemForPath(path: String ,error:NSErrorPointer) -> [String : AnyObject]? {
        var re = [String : AnyObject]()
        do {
            re = try self.attributesOfFileSystemForPath(path)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
            return nil
        }
        return re
    }
    func WQcopyItemAtPath(srcPath: String, toPath dstPath: String, error:NSErrorPointer) -> Bool {
        do {
            try self.copyItemAtPath(srcPath, toPath: dstPath)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
            return false
        }
        return true
    }
    func WQcontentsOfDirectoryAtPath(path: String, error:NSErrorPointer)  -> [String]? {
        var re = [String]()
        do {
            re = try self.contentsOfDirectoryAtPath(path)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
            return nil
        }
        return re
    }
}
extension NSFileHandle {
    public convenience init?(forWritingToURL url: NSURL ,error:NSErrorPointer) {
        do {
            try self.init(forWritingToURL:url)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
        }
        
    }
    public convenience init?(forReadingFromURL url: NSURL ,error:NSErrorPointer) {
        do {
            try self.init(forReadingFromURL:url)
        }catch let err as NSError {
            if error != nil {
                error.memory = err
            }
        }
        
    }
}
