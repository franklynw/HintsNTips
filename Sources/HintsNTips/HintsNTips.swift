//
//  HintsNTips.swift
//
//  Created by Franklyn Weber on 09/04/2021.
//

import SwiftUI


public struct HintsNTips: View {
    
    @Binding internal var config: Config?
    
    internal var font: UIFont?
    internal var textAlignment: NSTextAlignment = .center
    
    public struct Config: Identifiable {
        public let id: String
        let outlineRect: OutlineRect?
        let title: String
        let message: String?
        let textColor: UIColor
        let strokeColor: UIColor?
        let showNext: Button?
        let noMore: Button?
        
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
        
        public init(id: String, outlineRect: OutlineRect?, title: String, message: String? = nil, textColor: UIColor, strokeColor: UIColor? = nil, showNext: Button? = nil, noMore: Button? = nil) {
            self.id = id
            self.outlineRect = outlineRect
            self.title = title
            self.message = message
            self.textColor = textColor
            self.strokeColor = strokeColor
            self.showNext = showNext
            self.noMore = noMore
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



class HintsNTipsPresenter {
    
    private static var window: UIWindow?
    private static var viewController: UIViewController?
    private static var parent: HintsNTips!
    private static var box: UIView!
    
    static func present(parent: HintsNTips) {
        
        guard let appWindow = UIApplication.window else {
            return
        }
        guard window == nil else {
            return
        }
        
        self.parent = parent
        
        if let windowScene = appWindow.windowScene {
            
            let screenImage = screenGrab()
            
            let newWindow = UIWindow(windowScene: windowScene)
            
            window = newWindow
            window?.alpha = 0
            window?.makeKeyAndVisible()
            
            UIView.animate(withDuration: 0.3) {
                window?.alpha = 1
            } completion: { _ in
                
                if let screenImage = screenImage {
                    
                    addBlurredImage(withScreenGrab: screenImage)
                    
                    UIView.animate(withDuration: 0.3) {
                        box.alpha = 1
                    } completion: { _ in
                        draw(with: parent)
                    }
                    
                } else {
                    draw(with: parent)
                }
            }
            
            text(with: parent)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            window?.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    static func dismiss(withAction action: (() -> ())?) {
        
        guard window != nil else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            window?.alpha = 0
            viewController?.view.alpha = 0
        } completion: { _ in
            window = nil
            viewController = nil
            parent.config = nil
            action?()
        }
    }
    
    @objc
    private static func tapped() {
        dismiss(withAction: nil)
    }
    
    private static func text(with parent: HintsNTips) {
        
        guard let window = window, let config = parent.config else {
            return
        }
        
        let screenRect = UIScreen.main.bounds
        let screenSize = screenRect.size
        
        let outlineRect = config.outlineRect ?? HintsNTips.Config.OutlineRect(center: CGPoint(x: 0, y: 0.1), size: .zero)
        
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.layer.cornerRadius = 15
        box.layer.shadowRadius = 50
        box.layer.shadowColor = UIColor.black.cgColor
        box.layer.shadowOpacity = 0.2
        box.alpha = 0
        
        window.addSubview(box)
        
        let xPadding: CGFloat = 50
        
        box.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: xPadding).isActive = true
        box.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -xPadding).isActive = true
        
        if outlineRect.center.y > 0.5 {
            box.bottomAnchor.constraint(equalTo: window.topAnchor, constant: screenSize.height * outlineRect.center.y - outlineRect.size.height / 2 - 15).isActive = true
        } else {
            box.topAnchor.constraint(equalTo: window.topAnchor, constant: screenSize.height * outlineRect.center.y + outlineRect.size.height / 2 + 15).isActive = true
        }
        
        self.box = box
        
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = config.textColor
        titleLabel.text = config.title
        titleLabel.textAlignment = parent.textAlignment
        titleLabel.numberOfLines = 0
        
        if let font = parent.font {
            titleLabel.font = font.withWeight(.semibold)
        } else {
            titleLabel.font = titleLabel.font.withWeight(.semibold)
        }
        
        box.addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16).isActive = true
        titleLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: 16).isActive = true
        
        
        let buttonsView: UIView?
        
        if config.showNext != nil || config.noMore != nil {
            
            let buttons = UIStackView()
            buttons.translatesAutoresizingMaskIntoConstraints = false
            buttons.axis = .vertical
            buttons.distribution = .fillEqually
            
            if let showNext = config.showNext {
                
                let action = UIAction { _ in
                    dismiss(withAction: showNext.action)
                }
                let showNextButton = UIButton(primaryAction: action)
                showNextButton.setTitle(showNext.title, for: UIControl.State())
                showNextButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                
                buttons.addArrangedSubview(showNextButton)
            }
            if let noMore = config.noMore {
                
                let action = UIAction { _ in
                    dismiss(withAction: noMore.action)
                }
                let noMoreButton = UIButton(primaryAction: action)
                noMoreButton.setTitle(noMore.title, for: UIControl.State())
                noMoreButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                
                buttons.addArrangedSubview(noMoreButton)
            }
            
            box.addSubview(buttons)
            
            buttons.leadingAnchor.constraint(equalTo: box.leadingAnchor).isActive = true
            buttons.trailingAnchor.constraint(equalTo: box.trailingAnchor).isActive = true
            buttons.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -16).isActive = true
            
            buttonsView = buttons
            
        } else {
            buttonsView = nil
        }
        
        
        if let message = config.message {
            
            let messageLabel = UILabel()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.backgroundColor = .clear
            messageLabel.textColor = config.textColor
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = parent.textAlignment
            
            if let font = parent.font {
                messageLabel.font = font
            }
            
            box.addSubview(messageLabel)
            
            messageLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16).isActive = true
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
            
            if let buttonsView = buttonsView {
                messageLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -8).isActive = true
            } else {
                messageLabel.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -16).isActive = true
            }
            
        } else {
            if let buttonsView = buttonsView {
                titleLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -8).isActive = true
            } else {
                titleLabel.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -16).isActive = true
            }
        }
    }
    
    private static func draw(with parent: HintsNTips) {
        
        guard let window = window, let config = parent.config, let outlineRect = config.outlineRect else {
            return
        }
        
        let screenRect = UIScreen.main.bounds
        let screenSize = screenRect.size
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = screenRect
        
        shapeLayer.lineWidth = 5
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = (config.strokeColor ?? config.textColor).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        
        let center = CGPoint(x: outlineRect.center.x * screenSize.width, y: outlineRect.center.y * screenSize.height)
        let startPoint = CGPoint(x: center.x, y: center.y - outlineRect.size.height / 2)
        
        path.move(to: startPoint)
        
        let ctrlXLength = outlineRect.size.width / 2.5
        let ctrlYLength = outlineRect.size.height / 2.5
        let ctrlXOffset = outlineRect.size.width / 12
        let ctrlYOffset = outlineRect.size.height / 12
        
        func random(_ value: CGFloat) -> CGFloat {
            return CGFloat.random(in: -value...value)
        }
        
        func randomCut(_ value: CGFloat) -> CGFloat {
            let cut = CGFloat.random(in: 0.5...1)
            return value * cut
        }
        
        func plusOrMinus() -> CGFloat {
            return Int.random(in: 0...1) == 0 ? 1 : -1
        }
        
        let point2 = CGPoint(x: center.x + outlineRect.size.width / 2 + random(ctrlXOffset), y: center.y + random(ctrlYOffset))
        let ctrl2_1 = CGPoint(x: startPoint.x + randomCut(ctrlXLength), y: startPoint.y + randomCut(ctrlYOffset) * plusOrMinus())
        let ctrl2_xOffset = randomCut(ctrlXOffset) * plusOrMinus()
        let ctrl2_yOffset = randomCut(ctrlYLength)
        let ctrl2_2 = CGPoint(x: point2.x + ctrl2_xOffset, y: point2.y - ctrl2_yOffset)
        
        path.addCurve(to: point2, controlPoint1: ctrl2_1, controlPoint2: ctrl2_2)
        
        let point3 = CGPoint(x: center.x + random(ctrlXOffset), y: center.y + outlineRect.size.height / 2 + random(ctrlYOffset))
        let ctrl3_1 = CGPoint(x: point2.x - ctrl2_xOffset, y: point2.y + ctrl2_yOffset)
        let ctrl3_xOffset = randomCut(ctrlXLength)
        let ctrl3_yOffset = randomCut(ctrlYOffset) * plusOrMinus()
        let ctrl3_2 = CGPoint(x: point3.x + ctrl3_xOffset, y: point3.y + ctrl3_yOffset)
        
        path.addCurve(to: point3, controlPoint1: ctrl3_1, controlPoint2: ctrl3_2)
        
        let point4 = CGPoint(x: center.x - outlineRect.size.width / 2 + random(ctrlXOffset), y: center.y + random(ctrlYOffset))
        let ctrl4_1 = CGPoint(x: point3.x - ctrl3_xOffset, y: point3.y - ctrl3_yOffset)
        let ctrl4_xOffset = randomCut(ctrlXOffset) * plusOrMinus()
        let ctrl4_yOffset = randomCut(ctrlYLength)
        let ctrl4_2 = CGPoint(x: point4.x + ctrl4_xOffset, y: point4.y + ctrl4_yOffset)
        
        path.addCurve(to: point4, controlPoint1: ctrl4_1, controlPoint2: ctrl4_2)
        
        let endPoint = CGPoint(x: startPoint.x + randomCut(outlineRect.size.width / 6), y: startPoint.y + random(ctrlYOffset))
        let endCtrl1 = CGPoint(x: point4.x - ctrl4_xOffset, y: point4.y - ctrl4_yOffset)
        let endCtrl2 = CGPoint(x: endPoint.x - randomCut(ctrlXLength), y: endPoint.y + randomCut(ctrlYOffset) * plusOrMinus())
        
        path.addCurve(to: endPoint, controlPoint1: endCtrl1, controlPoint2: endCtrl2)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        shapeLayer.strokeEnd = 0
        
        window.layer.addSublayer(shapeLayer)
        
        shapeLayer.path = path.cgPath
        shapeLayer.add(animation, forKey: "stroke")
    }
    
    private static func screenGrab() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, true, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        UIApplication.shared.windows.first?.layer.render(in: context)
        let screenImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenImage
    }
    
    private static func addBlurredImage(withScreenGrab screenImage: UIImage) {
        
        let rect = box.frame
        
        let imageView = UIImageView(image: screenImage)
            
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.frame = imageView.bounds
        imageView.addSubview(visualEffectView)
        
        let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
        let blurredImage = renderer.image { context in
            imageView.drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: true)
        }
        
        guard let cgImage = blurredImage.cgImage, let cropped = cgImage.cropping(to: rect) else {
            return
        }
        
        let croppedImage = UIImage(cgImage: cropped)
        let blurredImageView = UIImageView(image: croppedImage)
        blurredImageView.translatesAutoresizingMaskIntoConstraints = false
        blurredImageView.layer.cornerRadius = 15
        blurredImageView.layer.masksToBounds = true
        
        box.insertSubview(blurredImageView, at: 0)
        
        blurredImageView.leadingAnchor.constraint(equalTo: box.leadingAnchor).isActive = true
        blurredImageView.trailingAnchor.constraint(equalTo: box.trailingAnchor).isActive = true
        blurredImageView.topAnchor.constraint(equalTo: box.topAnchor).isActive = true
        blurredImageView.bottomAnchor.constraint(equalTo: box.bottomAnchor).isActive = true
    }
}


extension UIFont {
    
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
