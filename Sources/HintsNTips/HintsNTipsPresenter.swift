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
    private static var outlineLayer: CALayer?
    private static var box: UIView!
    private static var exampleImage: UIImageView?
    private static var boxRect: CGRect!
    
    static func present(parent: HintsNTips) {
        
        guard window == nil, let windowScene = UIApplication.window?.windowScene else {
            return
        }
        guard let boxRect = estimateBoxRect(with: parent) else {
            return
        }
        
        self.parent = parent
        self.boxRect = boxRect
        
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
            
            UIView.animate(withDuration: 0.3) {
                container.alpha = 1
                box.transform = .identity
            } completion: { _ in
                draw(with: parent)
            }
        }
        
        box = addContent(to: container, with: parent, boxRect: boxRect)
        addBlurredImage(to: box, withScreenGrab: screenImage, inFrame: boxRect)
        shrink(view: box, with: parent, rect: boxRect)
        
        if !parent.showsCloseButton {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            window?.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    static func dismiss(withAction action: (() -> ())?) {
        
        guard window != nil else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            shrink(view: box, with: parent, rect: boxRect)
            box.alpha = 0
            exampleImage?.alpha = 0
            outlineLayer?.opacity = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                window?.alpha = 0
            } completion: { _ in
                window = nil
                parent.config = nil
                action?()
            }
        }
    }
    
    
    // MARK: Private
    
    @objc
    private static func tapped() {
        dismiss(withAction: nil)
    }
    
    private static let minBoxWidth: CGFloat = 260
    private static let minBoxEdgeSpace: CGFloat = 30
    private static let boxCornerRadius: CGFloat = 15
    private static let boxContentEdgePadding: CGFloat = 16
    private static let closeButtonRadius: CGFloat = 17
    private static let buttonPadding: CGFloat = 16
    private static let desiredAspect: CGFloat = 5 / 3
    private static let defaultFontSize: CGFloat = 16
    
    private static func estimateBoxRect(with parent: HintsNTips) -> CGRect? {
        
        guard let config = parent.config else {
            return nil
        }
        
        let screenSize = UIScreen.main.bounds.size
        let cgMax = CGFloat.greatestFiniteMagnitude
        
        let font = parent.font ?? UIFont.systemFont(ofSize: defaultFontSize)
        var height = boxContentEdgePadding * 2
        
        let maxBoxWidth = screenSize.width - minBoxEdgeSpace * 2
        let maxButtonWidth: CGFloat = config.buttons.reduce(0) {
            let buttonSize = $1.title.boundingRect(with: CGSize(width: cgMax, height: cgMax), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
            height += buttonSize.height + buttonPadding
            let buttonWidth = buttonSize.width
            return min(max(buttonWidth, $0), maxBoxWidth - boxContentEdgePadding * 2)
        }
        let maxTextWidth = maxBoxWidth - boxContentEdgePadding * 2
        
        // we approximate here, just for attractive layout
        let allText = config.title + (config.message != nil ? config.message! + "/n/n" : "")
        let approxTextSize = allText.boundingRect(with: CGSize(width: maxTextWidth, height: cgMax), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        let textArea = approxTextSize.width * approxTextSize.height
        let desiredTextWidth = max(min(sqrt(textArea * desiredAspect), maxBoxWidth - boxContentEdgePadding * 2), maxButtonWidth)
        
        let titleSize = config.title.boundingRect(with: CGSize(width: desiredTextWidth, height: cgMax), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font.withWeight(.semibold)], context: nil).size
        height += titleSize.height
        
        if let message = config.message {
            let messageSize = message.boundingRect(with: CGSize(width: desiredTextWidth, height: cgMax), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
            height += messageSize.height + boxContentEdgePadding
        }
        
        let width = max(desiredTextWidth, maxButtonWidth) + boxContentEdgePadding * 2
        
        let outlineRect = config.outlineRect ?? {
            let topSpace = (screenSize.height - height) / 3
            let y = topSpace / screenSize.height
            return HintsNTips.Config.OutlineRect(center: CGPoint(x: 0.5, y: y), size: .zero)
        }()
        let centerX = outlineRect.center.x * screenSize.width
        let centerY = outlineRect.center.y * screenSize.height
        let x = min(max(centerX - width / 2, minBoxEdgeSpace), screenSize.width - minBoxEdgeSpace - width)
        
        let y: CGFloat
        if outlineRect.center.y > 0.5 {
            y = centerY - outlineRect.size.height / 2 - boxContentEdgePadding - height
        } else {
            y = centerY + outlineRect.size.height / 2 + boxContentEdgePadding
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private static func addContent(to container: UIView, with parent: HintsNTips, boxRect: CGRect) -> UIView? {
        
        guard let config = parent.config else {
            return nil
        }
        
        let screenSize = UIScreen.main.bounds.size
        
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.layer.cornerRadius = boxCornerRadius
        box.layer.shadowRadius = 50
        box.layer.shadowColor = UIColor.black.cgColor
        box.layer.shadowOpacity = 0.2
        
        container.addSubview(box)
        
        box.pin(to: container, edges: [.leading(boxRect.minX), .trailing(screenSize.width - boxRect.maxX), .top(boxRect.minY)])
        
        
        let font = parent.font ?? UIFont.systemFont(ofSize: defaultFontSize)
        
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
        titleLabel.font = font.withWeight(.semibold)
        
        box.addSubview(titleLabel)
        
        titleLabel.pin(to: box, edges: [.leading(boxContentEdgePadding), .trailing(boxContentEdgePadding), .top(boxContentEdgePadding)])
        
        
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
                let attributedTitle = NSAttributedString(string: buttonConfig.title, attributes: [.font: font, NSAttributedString.Key.foregroundColor: parent.buttonColor ?? config.textColor.withAlphaComponent(0.5)])
                button.setAttributedTitle(attributedTitle, for: UIControl.State())
                button.contentEdgeInsets = UIEdgeInsets(top: buttonPadding / 2, left: boxContentEdgePadding, bottom: buttonPadding / 2, right: boxContentEdgePadding)
                
                buttons.addArrangedSubview(button)
            }
            
            box.addSubview(buttons)
            
            buttons.pin(to: box, edges: [.leading, .trailing, .bottom(boxContentEdgePadding)])
            
            buttonsView = buttons
            
        } else {
            buttonsView = nil
        }
        
        
        if let message = config.message {
            
            let messageLabel = contentLabel()
            messageLabel.text = message
            messageLabel.font = font
            
            box.addSubview(messageLabel)
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: boxContentEdgePadding).isActive = true
            
            if let buttonsView = buttonsView {
                messageLabel.pin(to: box, edges: [.leading(boxContentEdgePadding), .trailing(boxContentEdgePadding)])
                messageLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -boxContentEdgePadding / 2).isActive = true
            } else {
                messageLabel.pin(to: box, edges: [.leading(boxContentEdgePadding), .trailing(boxContentEdgePadding), .bottom(boxContentEdgePadding)])
            }
            
        } else {
            if let buttonsView = buttonsView {
                titleLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -boxContentEdgePadding / 2).isActive = true
            } else {
                titleLabel.pin(to: box, edges: [.bottom(boxContentEdgePadding)])
            }
        }
        
        if parent.showsCloseButton {
            
            func addConstraints(radius: CGFloat, to view: UIView) {
                view.widthAnchor.constraint(equalToConstant: radius * 2).isActive = true
                view.heightAnchor.constraint(equalToConstant: radius * 2).isActive = true
                view.centerXAnchor.constraint(equalTo: box.trailingAnchor).isActive = true
                view.centerYAnchor.constraint(equalTo: box.topAnchor).isActive = true
            }
            
            func addCircle(radius: CGFloat, to view: UIView) -> UIView {
                
                let circle = UIView()
                circle.translatesAutoresizingMaskIntoConstraints = false
                circle.layer.cornerRadius = radius
                
                view.addSubview(circle)
                addConstraints(radius: radius, to: circle)
                
                return circle
            }
            
            if let backgroundColor = parent.config?.backgroundColor {

                let dummyButton = addCircle(radius: closeButtonRadius - 3, to: box)
                let color = backgroundColor.equivalentColorWithNoTransparency.changeColor(componentDelta: -0.3)
                
                dummyButton.backgroundColor = color
                dummyButton.layer.shadowRadius = 5
                dummyButton.layer.shadowOffset = .zero
                dummyButton.layer.shadowColor = color.cgColor
                dummyButton.layer.shadowOpacity = 1
            }
            
            let styleConfig = UIImage.SymbolConfiguration(textStyle: .title1)
            let weightConfig = UIImage.SymbolConfiguration(weight: .semibold)
            let imageConfig = styleConfig.applying(weightConfig)
            let buttonImage = UIImage(systemName: "xmark.circle.fill")?.applyingSymbolConfiguration(imageConfig)
            
            let button = UIImageView(image: buttonImage)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = config.textColor
            
            box.addSubview(button)
            addConstraints(radius: closeButtonRadius, to: button)
            
            
            // because the above button is on box, its interactive area is clipped by the box bounds (as box clips its subviews)
            // easiest fix is to add an invisible button over it, which is directly on container
            
            let actionButton = addCircle(radius: closeButtonRadius, to: container)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            actionButton.addGestureRecognizer(tapGestureRecognizer)
        }
        
        return box
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
        
        let x = outlineRect.center.x * screenSize.width
        let y = outlineRect.center.y * screenSize.height
        let center = CGPoint(x: x, y: y)
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
        
        outlineLayer = shapeLayer
        
        func addExampleImage(_ image: UIImage, offsetBy offset: CGSize) {
            
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.alpha = 0
            
            container.insertSubview(imageView, at: 0)
            
            imageView.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: x + offset.width).isActive = true
            imageView.centerYAnchor.constraint(equalTo: container.topAnchor, constant: y + offset.height).isActive = true
            
            UIView.animate(withDuration: 0.3) {
                imageView.alpha = 1
            }
            
            exampleImage = imageView
        }
        
        switch config.exampleImage {
        case .centered(let image):
            addExampleImage(image, offsetBy: .zero)
        case .offset(let image, let offset):
            addExampleImage(image, offsetBy: offset)
        case .none:
            break
        }
    }
    
    private static func shrink(view: UIView, with parent: HintsNTips, rect: CGRect) {
        
        guard let config = parent.config else {
            return
        }
        
        let screenRect = UIScreen.main.bounds
        let screenSize = screenRect.size
        
        let outlineRect = config.outlineRect ?? HintsNTips.Config.OutlineRect(center: CGPoint(x: 0.5, y: 0.3), size: .zero)
        let centerX = outlineRect.center.x * screenSize.width
        let centerY = outlineRect.center.y * screenSize.height
        
        let xTranslation = centerX - rect.minX - rect.width / 2
        let yTranslation = centerY - rect.minY - rect.height / 2

        let scale = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translate = CGAffineTransform(translationX: xTranslation, y: yTranslation)
        let transform = scale.concatenating(translate)

        view.transform = transform
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
    
    private static func addBlurredImage(to view: UIView, withScreenGrab screenImage: UIImage?, inFrame frame: CGRect) {
        
        guard let screenImage = screenImage else {
            return
        }
        
        let scale = screenImage.scale
        let rect = CGRect(origin: CGPoint(x: frame.minX * scale, y: frame.minY * scale), size: CGSize(width: frame.width * scale, height: frame.height * scale))
        
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
        blurredImageView.layer.cornerRadius = boxCornerRadius
        blurredImageView.layer.masksToBounds = true
        
        view.insertSubview(blurredImageView, at: 0)
        
        blurredImageView.pin(to: view, edges: [.leading, .trailing, .top])
        blurredImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: croppedImage.size.height / croppedImage.size.width).isActive = true
        
        var cornerMask: CALayer {
            
            let radius: CGFloat = 18
            let bounds = CGRect(origin: .zero, size: frame.size)
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            
            let outerPath = UIBezierPath(rect: bounds)
            let innerPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: bounds.maxX - radius, y: -radius), size: CGSize(width: radius * 2, height: radius * 2)))
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
            backgroundView.layer.cornerRadius = boxCornerRadius
            backgroundView.layer.masksToBounds = true
            
            view.insertSubview(backgroundView, at: 1)
            
            backgroundView.pin(to: view, edges: [.leading, .trailing, .top])
            backgroundView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: croppedImage.size.height / croppedImage.size.width).isActive = true
            
            if parent.showsCloseButton {
                backgroundView.layer.mask = cornerMask
            }
        }
        
        if parent.showsCloseButton {
            blurredImageView.layer.mask = cornerMask
        }
    }
}
