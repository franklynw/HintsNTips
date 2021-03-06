//
//  HintsNTips.swift
//
//  Created by Franklyn Weber on 09/04/2021.
//

import SwiftUI


public protocol HintIdentifiable {
    var id: String { get }
}

public struct HintsNTips: View {
    
    @Binding internal var config: Config?
    
    internal var font: UIFont?
    internal var textAlignment: NSTextAlignment = .center
    internal var buttonColor: UIColor?
    internal var strokeDuration: TimeInterval = 1
    internal var showsCloseButton = false
    internal var userInterfaceStyle: UIUserInterfaceStyle = .unspecified
    
    public struct Config: HintIdentifiable {
        public let id: String
        let outlineRect: OutlineRect?
        let exampleImage: ExampleImage?
        let title: String
        let message: String?
        let textColor: UIColor
        let backgroundColor: UIColor?
        let strokeColor: UIColor?
        let buttons: [Button]
        
        public struct OutlineRect {
            let center: CGPoint
            let size: CGSize
            public init(center: CGPoint, size: CGSize) {
                self.center = center
                self.size = size
            }
        }
        
        public struct Button {
            let title: String
            let action: () -> ()
            public init(title: String, action: @escaping () -> ()) {
                self.title = title
                self.action = action
            }
        }
        
        public enum ExampleImage {
            case centered(UIImage)
            case offset(UIImage, CGSize)
        }
        
        public init(id: String, outlineRect: OutlineRect?, exampleImage: ExampleImage? = nil, title: String, message: String? = nil, textColor: UIColor, backgroundColor: UIColor? = nil, strokeColor: UIColor? = nil, buttons: [Button] = []) {
            self.id = id
            self.outlineRect = outlineRect
            self.exampleImage = exampleImage
            self.title = title
            self.message = message
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.strokeColor = strokeColor
            self.buttons = buttons
        }
    }
    
    
    public init(config: Binding<Config?>) {
        _config = config
    }
    
    public var body: some View {
        
        DoIf($config) {
            HintsNTipsPresenter.present(parent: self)
        } else: {
            HintsNTipsPresenter.dismiss(withAction: nil)
        }
    }
}
