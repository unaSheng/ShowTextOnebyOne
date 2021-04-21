//
//  TextAnimator.swift
//  TextShowedAnimation
//
//  Created by MOMO on 2021/4/21.
//

import UIKit

class ShapeView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
}

class TextAnimator: NSObject {
    
    let textMaskView = ShapeView()
    
    private let attributedText: NSAttributedString
    private let textView: UIView
    private var textBounds: CGRect
    private var cursorImageView: UIImageView?
    private var index: Int = 0
    private var paths: [CGPath] = []
    private var textRects: [CGRect] = []
    private var displayLink: CADisplayLink?
    private var font: UIFont!
    
    static func showText(_ attributedText: NSAttributedString, on view: UIView, cursor: UIImage?) -> TextAnimator {
        let animator = TextAnimator(attributedText: attributedText, on: view, cursorImage: cursor)
        return animator
    }
    
    init(attributedText: NSAttributedString, on textView: UIView, cursorImage: UIImage?) {
        self.attributedText = attributedText
        self.textView = textView
        self.textBounds = textView.bounds
        
        if let image = cursorImage {
            cursorImageView = UIImageView(image: image)
            cursorImageView?.frame = CGRect(origin: textView.frame.origin, size: image.size)
        }
        super.init()
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: 1), options: []) { (attributes, range, _) in
            if let font = attributes[.font] as? UIFont {
                self.font = font
            }
        }
    }
    
    func stopAnimation() {
        displayLink?.remove(from: .current, forMode: .common)
        displayLink?.invalidate()
        displayLink = nil
        textMaskView.shapeLayer.path = UIBezierPath(rect: textBounds).cgPath
        cursorImageView?.removeFromSuperview()
    }
    
    func startAnimation() {
        index = 0
        paths.removeAll()
        textRects.removeAll()
        let path = UIBezierPath()
        let textView = UITextView(frame: CGRect(origin: .zero, size: CGSize(width: textBounds.width, height: CGFloat.greatestFiniteMagnitude)))
        textView.attributedText = attributedText
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.layoutManager.ensureLayout(for: textView.textContainer)
        let bounds = textView.layoutManager.usedRect(for: textView.textContainer).integral
        textBounds = bounds
        textMaskView.frame = textBounds
        for index in 0 ..< attributedText.length {
            let start = textView.position(from: textView.beginningOfDocument, offset: index)!
            let end = textView.position(from: start, offset: 1)!
            let tRange = textView.textRange(from: start, to: end)!
            let rect = textView.firstRect(for: tRange)
            path.append(UIBezierPath(rect: rect))
            paths.append(path.cgPath)
            textRects.append(rect)
        }
        displayLink = CADisplayLink(target: self, selector: #selector(updateMaskPath))
        displayLink?.preferredFramesPerSecond = 10
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc private func updateMaskPath() {
        if index == paths.count {
            stopAnimation()
            return
        }
        self.textMaskView.shapeLayer.path = paths[index]
        let textRect = textRects[index]
        if let cursorImageView = self.cursorImageView {
            if cursorImageView.superview == nil {
                textView.superview?.addSubview(cursorImageView)
            }
            cursorImageView.frame = CGRect(x: textView.frame.origin.x + textRect.maxX, y: textView.frame.origin.y + textRect.minY, width: cursorImageView.bounds.width, height: font.lineHeight)
        }
        index += 1
    }
}
