//
//  UIApplication+Extensions.swift
//
//
//  Created by Franklyn Weber on 30/03/2021.
//

import UIKit


extension UIApplication {
    
    static var window: UIWindow? {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first
    }
}
