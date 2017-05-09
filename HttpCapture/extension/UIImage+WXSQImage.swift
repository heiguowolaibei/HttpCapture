//
//  UIImage+WXSQImage.swift
//  weixindress
//
//  Created by tianjie on 3/21/15.
//  Copyright (c) 2015 www.jd.com. All rights reserved.
//

import Foundation

extension UIImage {
    
    func transformToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    class func imageWithColor(color: UIColor, size:CGSize? = nil) -> UIImage {
        var rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        if size != nil
        {
            rect = CGRect(x: 0, y: 0, width: size!.width, height: size!.height)
        }
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func getDarkImg(frame:CGRect,cornerRadius:CGFloat,darkColor:UIColor) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.mainScreen().scale)
        let width = CGRectGetWidth(frame)
        let bounds = CGRectMake(0, 0, width, CGRectGetHeight(frame))
        var path = UIBezierPath(rect: bounds)
        path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        path.lineWidth = 1.0
        darkColor.setStroke()
        let pattern: [CGFloat] = [1.0]
        path.setLineDash(pattern, count: 1, phase: 0.0)
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func imageDash(frame:CGRect) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(frame.size, false, WXDevice.scale)
        let context = UIGraphicsGetCurrentContext()
        let width = CGRectGetWidth(frame)
        let height = CGRectGetHeight(frame)
        let bounds = CGRectMake(0, 0, width, CGRectGetHeight(frame))
        let path = UIBezierPath(rect: bounds)
        path.lineWidth = 2.0
        UIColor.fromRGBA(0x999999ff).setStroke()
        let pattern: [CGFloat] = [1.0 ]//, 2.0,2.0]
        path.setLineDash(pattern, count: 1, phase: 0.0)
        path.stroke()
        
        let img = UIImage(named: "添加搭配")
        let imgSize = img!.size
        img!.drawInRect(CGRectMake((width-imgSize.height)/2.0,(height-imgSize.height)/2.0,imgSize.width,imgSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
//    class func circleImage(radius:CGFloat) -> UIImage  {
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius*2, radius*2), false, WXDevice.scale)
//        let context = UIGraphicsGetCurrentContext()
// 
//        UIColor.blackColor().setFill()
//        CGContextAddArc(context!,radius, radius, radius, 0, CGFloat(2*M_PI), 0)
//        CGContextDrawPath(context, kCGPathFill);//绘制填充
//        
//       
//        CGContextSetShouldAntialias(context, true)
//        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
}