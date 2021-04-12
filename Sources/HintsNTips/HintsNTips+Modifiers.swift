//
//  File.swift
//  
//
//  Created by Franklyn Weber on 09/04/2021.
//

import SwiftUI


extension HintsNTips {
    
    public func font(_ font: UIFont) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
    
    public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        var copy = self
        copy.textAlignment = textAlignment
        return copy
    }
    
    public func buttonColor(_ buttonColor: UIColor) -> Self {
        var copy = self
        copy.buttonColor = buttonColor
        return copy
    }
    
    public func strokeDuration(_ strokeDuration: TimeInterval) -> Self {
        var copy = self
        copy.strokeDuration = strokeDuration
        return copy
    }
    
    public var showCloseButton: Self {
        var copy = self
        copy.showsCloseButton = true
        return copy
    }
}
