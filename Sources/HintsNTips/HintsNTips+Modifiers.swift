//
//  File.swift
//  
//
//  Created by Franklyn Weber on 09/04/2021.
//

import SwiftUI


extension HintsNTips {
    
    func font(_ font: UIFont) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
    
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        var copy = self
        copy.textAlignment = textAlignment
        return copy
    }
}
