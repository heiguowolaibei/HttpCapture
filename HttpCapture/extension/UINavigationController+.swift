//
//  UINavigationController+.swift
//  weixindress
//
//  Created by timothywei on 15/4/2.
//  Copyright (c) 2015年 www.jd.com. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func popViewControllerWithHandler(animated: Bool, completion: () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewControllerAnimated(animated)
        CATransaction.commit()
    }
    
    func pushViewController(animated: Bool, viewController: UIViewController, completion: () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}