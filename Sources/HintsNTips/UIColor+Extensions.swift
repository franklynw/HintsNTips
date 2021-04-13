//
//  UIColor+Extensions.swift
//  
//
//  Created by Franklyn Weber on 13/04/2021.
//

import UIKit


extension UIColor {
    
    func changeColor(componentDelta: CGFloat) -> UIColor {
        
        guard let components = self.cgColor.components else { return self }
        
        func add(_ value: CGFloat, to: CGFloat) -> CGFloat {
            return max(0, min(1, to + value))
        }
        
        let red = add(componentDelta, to: components[0])
        let green = add(componentDelta, to: components[1])
        let blue = add(componentDelta, to: components[2])
        
        let alpha: CGFloat
        if components.count == 4 {
            alpha = components[3]
        } else {
            alpha = 1
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
