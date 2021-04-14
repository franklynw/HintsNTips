//
//  UIView+Extensions.swift
//  
//
//  Created by Franklyn Weber on 13/04/2021.
//

import UIKit


extension UIView {
    
    struct Constraints {
        let leading: NSLayoutConstraint?
        let trailing: NSLayoutConstraint?
        let top: NSLayoutConstraint?
        let bottom: NSLayoutConstraint?
        let centerX: NSLayoutConstraint?
        let centerY: NSLayoutConstraint?
    }
    
    enum Edges: Equatable {
        case leading(CGFloat)
        case trailing(CGFloat)
        case top(CGFloat)
        case bottom(CGFloat)
        case centerX(CGFloat)
        case centerY(CGFloat)
        
        static var leading = Edges.leading(0)
        static var trailing = Edges.trailing(0)
        static var top = Edges.top(0)
        static var bottom = Edges.bottom(0)
        static var centerX = Edges.centerX(0)
        static var centerY = Edges.centerY(0)
        
        static func ==(_ lhs: Edges, _ rhs: Edges) -> Bool {
            switch (lhs, rhs) {
            case (.leading, .leading), (.trailing, .trailing), (.top, .top), (.bottom, .bottom), (.centerX, .centerX), (.centerY, .centerY):
                return true
            default:
                return false
            }
        }
        
        fileprivate var value: CGFloat {
            switch self {
            case .leading(let value), .trailing(let value), .top(let value), .bottom(let value), .centerX(let value), .centerY(let value):
                return value
            }
        }
    }
    
    @discardableResult
    func pin(to view: UIView, edges: [Edges] = [.leading(0), .trailing(0), .top(0), .bottom(0)]) -> Constraints {
        
        let leading: NSLayoutConstraint?
        if let leadingInset = edges.first(where: { $0 == .leading }) {
            leading = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingInset.value)
            leading?.isActive = true
        } else {
            leading = nil
        }
        
        let trailing: NSLayoutConstraint?
        if let trailingInset = edges.first(where: { $0 == .trailing }) {
            trailing = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingInset.value)
            trailing?.isActive = true
        } else {
            trailing = nil
        }
        
        let top: NSLayoutConstraint?
        if let topInset = edges.first(where: { $0 == .top }) {
            top = topAnchor.constraint(equalTo: view.topAnchor, constant: topInset.value)
            top?.isActive = true
        } else {
            top = nil
        }
        
        let bottom: NSLayoutConstraint?
        if let bottomInset = edges.first(where: { $0 == .bottom }) {
            bottom = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomInset.value)
            bottom?.isActive = true
        } else {
            bottom = nil
        }
        
        let centerX: NSLayoutConstraint?
        if let centerXConstant = edges.first(where: { $0 == .centerX }) {
            centerX = centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -centerXConstant.value)
            centerX?.isActive = true
        } else {
            centerX = nil
        }
        
        let centerY: NSLayoutConstraint?
        if let centerYConstant = edges.first(where: { $0 == .centerY }) {
            centerY = centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -centerYConstant.value)
            centerY?.isActive = true
        } else {
            centerY = nil
        }
        
        return Constraints(leading: leading, trailing: trailing, top: top, bottom: bottom, centerX: centerX, centerY: centerY)
    }
}
