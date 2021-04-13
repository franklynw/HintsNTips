//
//  HintsNTipsPresenter.swift
//  
//
//  Created by Franklyn Weber on 09/04/2021.
//

import SwiftUI


class HintsNTipsPresenter {
    
    private static var window: UIWindow?
    private static var parent: HintsNTips!
    private static var container: UIView!
    private static var box: UIView!
    
    static func present(parent: HintsNTips) {
        
        guard window == nil, let windowScene = UIApplication.window?.windowScene else {
            return
        }
        
        self.parent = parent
        
        let screenImage = screenGrab()
        let newWindow = UIWindow(windowScene: windowScene)
        
        window = newWindow
        window?.alpha = 0
        window?.makeKeyAndVisible()
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0
        
        window?.addSubview(container)
        
        container.pin(to: newWindow)
        
        self.container = container
        
        UIView.animate(withDuration: 0.3) {
            window?.alpha = 1
        } completion: { _ in
            
            if let screenImage = screenImage {
                
                addBlurredImage(withScreenGrab: screenImage)
                
                UIView.animate(withDuration: 0.3) {
                    container.alpha = 1
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
    
    static func dismiss(withAction action: (() -> ())?) {
        
        guard window != nil else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            window?.alpha = 0
        } completion: { _ in
            window = nil
            parent.config = nil
            action?()
        }
    }
    
    @objc
    private static func tapped() {
        dismiss(withAction: nil)
    }
    
    private static func text(with parent: HintsNTips) {
        
        guard let config = parent.config else {
            return
        }
        
        let screenRect = UIScreen.main.bounds
        let screenSize = screenRect.size
        let edgePadding: CGFloat = 16
        
        let outlineRect = config.outlineRect ?? HintsNTips.Config.OutlineRect(center: CGPoint(x: 0, y: 0.1), size: .zero)
        
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.layer.cornerRadius = 15
        box.layer.shadowRadius = 50
        box.layer.shadowColor = UIColor.black.cgColor
        box.layer.shadowOpacity = 0.2
        
        container.addSubview(box)
        
        box.pin(to: container, edges: [.leading(50), .trailing(50)])
        
        if outlineRect.center.y > 0.5 {
            box.bottomAnchor.constraint(equalTo: container.topAnchor, constant: screenSize.height * outlineRect.center.y - outlineRect.size.height / 2 - edgePadding).isActive = true
        } else {
            box.pin(to: container, edges: [.top(screenSize.height * outlineRect.center.y + outlineRect.size.height / 2 + edgePadding)])
        }
        
        self.box = box
        
        
        func contentLabel() -> UILabel {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .clear
            label.textColor = config.textColor
            label.textAlignment = parent.textAlignment
            label.numberOfLines = 0
            return label
        }
        
        let titleLabel = contentLabel()
        titleLabel.text = config.title
        
        if let font = parent.font {
            titleLabel.font = font.withWeight(.semibold)
        } else {
            titleLabel.font = titleLabel.font.withWeight(.semibold)
        }
        
        box.addSubview(titleLabel)
        
        titleLabel.pin(to: box, edges: [.leading(edgePadding), .trailing(edgePadding), .top(edgePadding)])
        
        
        let buttonsView: UIView?
        
        if !config.buttons.isEmpty {
            
            let buttons = UIStackView()
            buttons.translatesAutoresizingMaskIntoConstraints = false
            buttons.axis = .vertical
            buttons.distribution = .fillEqually
            
            config.buttons.forEach { buttonConfig in
                
                let action = UIAction { _ in
                    dismiss(withAction: buttonConfig.action)
                }
                let button = UIButton(primaryAction: action)
                button.setTitle(buttonConfig.title, for: UIControl.State())
                button.contentEdgeInsets = UIEdgeInsets(top: edgePadding / 2, left: edgePadding, bottom: edgePadding / 2, right: edgePadding)
                
                if let buttonColor = parent.buttonColor {
                    button.tintColor = buttonColor
                }
                
                buttons.addArrangedSubview(button)
            }
            
            box.addSubview(buttons)
            
            buttons.pin(to: box, edges: [.leading, .trailing, .bottom(edgePadding)])
            
            buttonsView = buttons
            
        } else {
            buttonsView = nil
        }
        
        
        if let message = config.message {
            
            let messageLabel = contentLabel()
            messageLabel.text = message
            
            if let font = parent.font {
                messageLabel.font = font
            }
            
            box.addSubview(messageLabel)
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: edgePadding).isActive = true
            
            if let buttonsView = buttonsView {
                messageLabel.pin(to: box, edges: [.leading(edgePadding), .trailing(edgePadding)])
                messageLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -edgePadding / 2).isActive = true
            } else {
                messageLabel.pin(to: box, edges: [.leading(edgePadding), .trailing(edgePadding), .bottom(edgePadding)])
            }
            
        } else {
            if let buttonsView = buttonsView {
                titleLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -edgePadding / 2).isActive = true
            } else {
                titleLabel.pin(to: box, edges: [.bottom(edgePadding)])
            }
        }
        
        if parent.showsCloseButton {
            
            func addButton(name: String, action: UIAction) -> UIButton {
                
                let styleConfig = UIImage.SymbolConfiguration(textStyle: .title1)
                let fontConfig = UIImage.SymbolConfiguration(weight: .semibold)
                let imageConfig = styleConfig.applying(fontConfig)
                let buttonImage = UIImage(systemName: name)?.applyingSymbolConfiguration(imageConfig)
                
                let button = UIButton(primaryAction: action)
                button.setImage(buttonImage, for: UIControl.State())
                button.translatesAutoresizingMaskIntoConstraints = false
                button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                
                box.addSubview(button)

                button.centerXAnchor.constraint(equalTo: box.trailingAnchor).isActive = true
                button.centerYAnchor.constraint(equalTo: box.topAnchor).isActive = true
                
                return button
            }
            
            if let backgroundColor = parent.config?.backgroundColor {
                
                let dummyButton = addButton(name: "circle.fill", action: UIAction { _ in })
                
                dummyButton.tintColor = backgroundColor
                dummyButton.layer.shadowRadius = 2
                dummyButton.layer.shadowOffset = .zero
                dummyButton.layer.shadowColor = backgroundColor.changeColor(componentDelta: -0.5).cgColor
                dummyButton.layer.shadowOpacity = 1
            }
            
            let action = UIAction { _ in
                dismiss(withAction: nil)
            }
            
            let closeButton = addButton(name: "xmark.circle.fill", action: action)
            
            if let buttonColor = parent.buttonColor {
                closeButton.tintColor = buttonColor
            }
        }
    }
    
    private static func draw(with parent: HintsNTips) {
        
        guard let config = parent.config, let outlineRect = config.outlineRect else {
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
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeEnd = 0
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = parent.strokeDuration
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        shapeLayer.add(animation, forKey: nil)
        
        container.layer.addSublayer(shapeLayer)
    }
    
    private static func screenGrab() -> UIImage? {
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, true, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        UIApplication.shared.windows.first?.layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private static func addBlurredImage(withScreenGrab screenImage: UIImage) {
        
        let scale = screenImage.scale
        let rect = CGRect(origin: CGPoint(x: box.frame.minX * scale, y: box.frame.minY * scale), size: CGSize(width: box.frame.width * scale, height: box.frame.height * scale))
        
        let imageView = UIImageView(image: screenImage)
            
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
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
        
        blurredImageView.pin(to: box, edges: [.leading, .trailing, .top])
        blurredImageView.heightAnchor.constraint(equalTo: box.widthAnchor, multiplier: croppedImage.size.height / croppedImage.size.width).isActive = true
        
        var cornerMask: CALayer {
            
            let radius: CGFloat = 18
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = box.bounds
            
            let outerPath = UIBezierPath(rect: box.bounds)
            let innerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: box.bounds.maxX - radius, y: -radius), size: CGSize(width: radius * 2, height: radius * 2)))
            outerPath.append(innerPath)
            
            maskLayer.path = outerPath.cgPath
            maskLayer.fillColor = UIColor.black.cgColor
            maskLayer.fillRule = .evenOdd
            
            return maskLayer
        }
        
        if let backgroundColor = parent.config?.backgroundColor {
            
            let backgroundView = UIView()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.backgroundColor = backgroundColor
            backgroundView.layer.cornerRadius = 15
            backgroundView.layer.masksToBounds = true
            
            box.insertSubview(backgroundView, at: 1)
            
            backgroundView.pin(to: box, edges: [.leading, .trailing, .top])
            backgroundView.heightAnchor.constraint(equalTo: box.widthAnchor, multiplier: croppedImage.size.height / croppedImage.size.width).isActive = true
            
            if parent.showsCloseButton {
                backgroundView.layer.mask = cornerMask
            }
        }
        
        if parent.showsCloseButton {
            blurredImageView.layer.mask = cornerMask
        }
    }
}
