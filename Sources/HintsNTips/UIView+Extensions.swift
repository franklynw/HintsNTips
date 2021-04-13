//
//  UIView+Extensions.swift
//  
//
//  Created by Franklyn Weber on 13/04/2021.
//

import UIKit


extension UIView {
    
    struct EdgeConstraints {
        let leading: NSLayoutConstraint?
        let trailing: NSLayoutConstraint?
        let top: NSLayoutConstraint?
        let bottom: NSLayoutConstraint?
    }
    
    enum Edges: Equatable {
        case leading(CGFloat)
        case trailing(CGFloat)
        case top(CGFloat)
        case bottom(CGFloat)
        
        static var leading = Edges.leading(0)
        static var trailing = Edges.trailing(0)
        static var top = Edges.top(0)
        static var bottom = Edges.bottom(0)
        
        static func ==(_ lhs: Edges, _ rhs: Edges) -> Bool {
            switch (lhs, rhs) {
            case (.leading, .leading), (.trailing, .trailing), (.top, .top), (.bottom, .bottom):
                return true
            default:
                return false
            }
        }
        
        var inset: CGFloat {
            switch self {
            case .leading(let inset), .trailing(let inset), .top(let inset), .bottom(let inset):
                return inset
            }
        }
    }
    
    @discardableResult
    func pin(to view: UIView, edges: [Edges] = [.leading(0), .trailing(0), .top(0), .bottom(0)]) -> EdgeConstraints {
        
        let leading: NSLayoutConstraint?
        if let leadingInset = edges.first(where: { $0 == .leading }) {
            leading = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingInset.inset)
            leading?.isActive = true
        } else {
            leading = nil
        }
        
        let trailing: NSLayoutConstraint?
        if let trailingInset = edges.first(where: { $0 == .trailing }) {
            trailing = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingInset.inset)
            trailing?.isActive = true
        } else {
            trailing = nil
        }
        
        let top: NSLayoutConstraint?
        if let topInset = edges.first(where: { $0 == .top }) {
            top = topAnchor.constraint(equalTo: view.topAnchor, constant: topInset.inset)
            top?.isActive = true
        } else {
            top = nil
        }
        
        let bottom: NSLayoutConstraint?
        if let bottomInset = edges.first(where: { $0 == .bottom }) {
            bottom = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomInset.inset)
            bottom?.isActive = true
        } else {
            bottom = nil
        }
        
        return EdgeConstraints(leading: leading, trailing: trailing, top: top, bottom: bottom)
    }
}
