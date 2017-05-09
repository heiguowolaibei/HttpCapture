//
//  CommonNavigationView.swift
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/12.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

import Foundation
import UIKit

class NavigationButton:UIButton {
    
    override var frame:CGRect {
        get
        {
            return  super.frame
        }
        
        set
        {
            let newFrame = CGRect(x: 0, y: newValue.minY, width: newValue.width, height: newValue.height)
            super.frame = newFrame
        }
    }
}


class NavigationRightView:UIView {
    
    override var frame:CGRect {
        get
        {
            return super.frame
        }
        
        set
        {
            let _x:CGFloat = WXDevice.width - newValue.width
            let newFrame = CGRect(x: _x, y: newValue.minY, width: newValue.width, height: newValue.height)
            super.frame = newFrame
        }
    }
}

class UIRightButton: UIButton {
    var normalFrame = CGRectZero
    
    override var frame:CGRect{
        get {
            return normalFrame
        }
        
        set {
            super.frame = normalFrame
        }
    }
}

class NavigationRightButton:UIButton {
    
    override var frame:CGRect {
        get
        {
            return super.frame
        }
        
        set
        {
            let _x:CGFloat = WXDevice.width - newValue.width
            let newFrame = CGRect(x: _x, y: newValue.minY, width: newValue.width, height: newValue.height)
            super.frame = newFrame
        }
    }
}



