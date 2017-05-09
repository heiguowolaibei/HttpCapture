//
//  FileHelper.swift
//  weixindress
//
//  Created by timothywei on 15/3/12.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation


class FileHelper {
    static var maxCacheAge = 60 * 60 * 24 * 7
    static var FileManager = NSFileManager.defaultManager()
    static var DocumentRoot =  NSFileManager.defaultManager().WQURLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)
    
    static var CacheRoot =  NSFileManager.defaultManager().WQURLForDirectory(NSSearchPathDirectory.CachesDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)
    
    static var CacheRootPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask,true)[0] ;
    
    static var DocumentRootPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask,true)[0] ;
    
    static var TempRootPath = NSTemporaryDirectory();
    
         // 生成文件夹
    class func createDirectoryNotExist(folderPath:NSURL) -> Void {
        let isExist = FileHelper.FileManager.fileExistsAtPath(folderPath.path!)
        if !isExist {
            FileHelper.FileManager.WQcreateDirectoryAtURL(folderPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }
    
    class func createDirectoryNotExistWithPath(folderPath:String) -> Void {
        let isExist = FileHelper.FileManager.fileExistsAtPath(folderPath)
        if !isExist {
            FileHelper.FileManager.WQcreateDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }
    
    class func createDirectoryInDocumentsNotExistWithPathName(name:String) {
        let directory = DocumentRootPath.stringByAppendingPathComponent("\(name)")
        var isDirectory:UnsafeMutablePointer<ObjCBool> = UnsafeMutablePointer<ObjCBool>.alloc(sizeof(ObjCBool))
        isDirectory.initialize(ObjCBool(true))
        if FileManager.fileExistsAtPath(directory, isDirectory: isDirectory) == false {
            FileManager.WQcreateDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        isDirectory.destroy()
        isDirectory.dealloc(sizeof(ObjCBool))
    }
    
    class func createPathInDocumentsNotExist(name:String) -> String {
        if name == "" {
            return DocumentRootPath
        }
        let componets:[String] = name.componentsSeparatedByString("/")
        let count = componets.count
        if count > 1 {
            for i in 0 ..< count {
                let n:String = componets[i]
                if i < (count - 1) {
                    self.createDirectoryInDocumentsNotExistWithPathName(n)
                }
            }
        }
        
        let path = DocumentRootPath.stringByAppendingPathComponent("\(name)")
        var isDirectory:UnsafeMutablePointer<ObjCBool> = UnsafeMutablePointer<ObjCBool>.alloc(sizeof(ObjCBool))
        isDirectory.initialize(ObjCBool(false))
        if FileManager.fileExistsAtPath(path, isDirectory: isDirectory) == false {
            FileManager.createFileAtPath(path, contents: nil, attributes: nil)
        }
        isDirectory.destroy()
        isDirectory.dealloc(sizeof(ObjCBool))
        return path
    }
    
    class func getFileSizeAtPath(path:NSString) -> UInt64 {
        var isDir:ObjCBool = false
        
        if FileHelper.FileManager.fileExistsAtPath(path as String, isDirectory: &isDir) == false {
            return 0
        }
        
        if isDir {
            var total:UInt64 = 0
            
            if let fileNames:[AnyObject] = FileHelper.FileManager.subpathsAtPath(path as String) {
                for subPath:AnyObject in fileNames {
                    total = total + FileHelper.getFileSizeAtPath(path.stringByAppendingPathComponent("\(subPath)"))
                }
            }
            
            return total
        }
        else
        {
            if let dict:NSDictionary = FileHelper.FileManager.WQattributesOfItemAtPath(path as String, error: nil) {
                return dict.fileSize()
            }
        }
        
        return 0
    }
    
    //删除指定文件夹里的过期文件
    class func onRemoveExpirationFile(diskCachePath:String) {
        let diskCacheURL = NSURL(fileURLWithPath: diskCachePath, isDirectory: true)
            let resourceKeys = [NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey]
            let _fileManager = FileHelper.FileManager
            let fileEnumerator = _fileManager.enumeratorAtURL(diskCacheURL, includingPropertiesForKeys: resourceKeys, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, errorHandler: nil)
            let expirationDate = NSDate(timeIntervalSinceNow: -Double(maxCacheAge))
            let urlsToDelete = NSMutableArray()
            
            while let item: AnyObject = fileEnumerator?.nextObject(){
                if item is NSURL{
                    let fileURL = item as! NSURL
                    let resourceValues = try? fileURL.resourceValuesForKeys(resourceKeys)
                        if let isDirValue: AnyObject? = resourceValues![NSURLIsDirectoryKey]//叹号啊
                        {
                            if isDirValue?.boolValue == true{
                                continue
                            }
                        }
                        
                        let modificationDate: AnyObject? = resourceValues![NSURLContentModificationDateKey]//叹号啊
                        if modificationDate is NSDate{
                            let m_modificationDate = modificationDate as! NSDate
                            if m_modificationDate.laterDate(expirationDate).isEqualToDate(expirationDate){
                                urlsToDelete.addObject(item)
                                continue
                            }
                        }
                    
                }
            }
            
            for item in urlsToDelete{
                if item is NSURL{
                    _fileManager.WQremoveItemAtURL(item as! NSURL, error: nil)
                }
            }
        
    }
    
    class func freeDiskSpace()-> Int
    {
        //    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
        //    return [fattributes objectForKey:NSFileSystemFreeSize];
        var  fattributes = NSFileManager.defaultManager().WQattributesOfFileSystemForPath(NSHomeDirectory(), error: nil);
        if fattributes != nil
        {
            if let freeDiskSize = fattributes![NSFileSystemFreeSize] as? NSNumber
            {
                return freeDiskSize.integerValue
            }
        }
        return 0
    }
    
    // 添加忽略iCloud自动备份
    class func addSkipBackupAttributeToItemAtPath(filePathString:String) -> Bool
    {
        var success:Bool = false
        let url =  NSURL(fileURLWithPath: filePathString)
        
            if FileHelper.FileManager.fileExistsAtPath(filePathString) {
                do {
                    try url.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
                } catch let err as NSError {
                        success = false
                        DPrintln("\(err)")
                }
                success = true
                DPrintln("addSkipBackupAttributeToItemAtPath success.")
                
            }
            
        
        return success;
    }
}