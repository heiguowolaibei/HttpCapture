//
//  UISearchBar+Subview.swift
//  weixindress
//
//  Created by kevin on 16/2/23.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

import Foundation

extension UISearchBar {
    
    var textField:UITextField? {
        get {
            let _textField:UITextField? = self.getTextField()
            return _textField
        }
    }
    
    var cancelButton:UIButton? {
        get {
            return self.getCancelButton()
        }
    }
    
    private func getTextField() -> UITextField? {
        if let  v = self.valueForKey("_searchField") as? UITextField {
            
            return v
        }
        
        let searchBarViews:[UIView] = self.subviews
        for v in searchBarViews {
            let views:[UIView] = v.subviews
            for vi in views {
                if let Class_SearchBarTextField = NSClassFromString("UISearchBarTextField") where vi.isKindOfClass(Class_SearchBarTextField) {//叹号啊
                    if let f = vi as? UITextField {
                        return f
                    }
                }
            }
        }
        return nil
    }
    
    
    
    private func getCancelButton() -> UIButton? {
        self.showsCancelButton = true
        if let  b = self.valueForKey("_cancelButton") as? UIButton {
            return b
        }
        
        let searchBarViews:[UIView] = self.subviews
        for v in searchBarViews {
            let views:[UIView] = v.subviews
            for vi in views {
                if let Class_cancelButton = NSClassFromString("UINavigationButton") where vi.isKindOfClass(Class_cancelButton) {//叹号啊
                    if let b = vi as? UIButton {
                        return b
                    }
                }
            }
        }
        return nil
    }

    
}