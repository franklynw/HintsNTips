//
//  DoIf.swift
//
//  Created by Franklyn Weber on 30/01/2021.
//

import SwiftUI


struct DoIf<T>: View {
    
    private var binding: Binding<T?>
    private let action: () -> ()
    private let otherAction: (() -> ())?
    
    
    init(_ binding: Binding<T?>, _ action: @escaping () -> (), else otherAction: (() -> ())? = nil) {
        self.binding = binding
        self.action = action
        self.otherAction = otherAction
    }
    
    var body: some View {
        
        return If(binding) { () -> EmptyView in
            self.action()
            return EmptyView()
        } else: { () -> EmptyView in
            self.otherAction?()
            return EmptyView()
        }
    }
}


struct If<T>: View {
    
    private let viewProvider: () -> AnyView
    
    init<V: View, O: View>(_ binding: Binding<T?>, @ViewBuilder _ viewProvider: @escaping () -> V, @ViewBuilder else otherViewProvider: @escaping () -> O) {
        self.viewProvider = {
            if let w = binding.wrappedValue {
                return AnyView(viewProvider())
            } else {
                return AnyView(otherViewProvider())
            }
        }
    }
    
    var body: some View {
        return viewProvider()
    }
}
