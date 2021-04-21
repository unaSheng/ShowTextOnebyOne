//
//  ViewController.swift
//  TextShowedAnimation
//
//  Created by MOMO on 2021/4/19.
//

import UIKit

class ShapeView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
}

class TextCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
    let textMaskView = ShapeView()
    var paths: [CGPath] = []
    var index: Int = 0
    var displayLink: CADisplayLink?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textMaskView.frame = textView.bounds
        textView.mask = textMaskView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopDisplayLink()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            stopDisplayLink()
        }
    }
    
    func stopDisplayLink() {
        displayLink?.remove(from: .current, forMode: .common)
        displayLink?.invalidate()
        displayLink = nil
        textMaskView.shapeLayer.path = UIBezierPath(rect: textView.bounds).cgPath
    }
    
    func startAnimation() {
        index = 0
        paths.removeAll()
        let path = UIBezierPath()
        let startTime = DispatchTime.now()
        let _start = CFAbsoluteTimeGetCurrent()
        for index in 0 ..< textView.text.count {
            textView.layoutManager.ensureLayout(for: textView.textContainer)
            let start = textView.position(from: textView.beginningOfDocument, offset: index)!
            let end = textView.position(from: start, offset: 1)!
            let tRange = textView.textRange(from: start, to: end)!
            let rect = textView.firstRect(for: tRange)
            path.append(UIBezierPath(rect: rect))
            paths.append(path.cgPath)
            
            //            DispatchQueue.main.asyncAfter(deadline: startTime + Double(index) * 0.1, execute: {
            //                self.textMaskView.shapeLayer.path = paths[index]
            //                print("set path index: \(index), timeoffset: \(CFAbsoluteTimeGetCurrent() - _start)")
            //            })
            
            //            let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            //            timer.setEventHandler(handler: {
            //                self.textMaskView.shapeLayer.path = paths[index]
            //                print("set path index: \(index), timeoffset: \(CFAbsoluteTimeGetCurrent() - _start)")
            //                let _ = timer
            //            })
            //            timer.schedule(deadline: startTime + Double(index) * 0.1)
            //            timer.resume()
            //
            //            Timer.scheduledTimer(withTimeInterval: Double(index) * 0.1, repeats: false, block: {_ in
            //                self.textMaskView.shapeLayer.path = paths[index]
            //                print("set path index: \(index), timeoffset: \(CFAbsoluteTimeGetCurrent() - _start)")
            //            })
        }
        displayLink = CADisplayLink(target: self, selector: #selector(updateMaskPath))
        displayLink?.preferredFramesPerSecond = 10
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc func updateMaskPath() {
        if index == paths.count {
            stopDisplayLink()
            return
        }
        self.textMaskView.shapeLayer.path = paths[index]
        index += 1
    }
}

extension UILabel {
    func boundingRectForCharacterRange(_ range: NSRange) -> CGRect? {
        guard let attributedText = attributedText else { return nil }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        layoutManager.addTextContainer(textContainer)
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        let size = CGSize(width: rect.width, height: max(self.font.lineHeight, rect.height))
        rect.size = size
        return rect
    }
}

class TextLabelCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    let textMaskView = ShapeView()
    var paths: [CGPath] = []
    var index: Int = 0
    var displayLink: CADisplayLink?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.lineHeightMultiple = 1
        textLabel.attributedText = NSAttributedString(string: textLabel.text!, attributes: [.font: textLabel.font!, .link: "http://www.google.com", .paragraphStyle: paragraphStyle])
        
        textMaskView.frame = textLabel.bounds
        textLabel.mask = textMaskView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopDisplayLink()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            stopDisplayLink()
        }
    }
    
    func stopDisplayLink() {
        displayLink?.remove(from: .current, forMode: .common)
        displayLink?.invalidate()
        displayLink = nil
        textMaskView.shapeLayer.path = UIBezierPath(rect: textLabel.bounds).cgPath
    }
    
    func startAnimation() {
        index = 0
        paths.removeAll()
        let path = UIBezierPath()
        let textView = UITextView(frame: textLabel.bounds)
        textView.attributedText = textLabel.attributedText
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        for index in 0 ..< textLabel.text!.count {
            textView.layoutManager.ensureLayout(for: textView.textContainer)
            let start = textView.position(from: textView.beginningOfDocument, offset: index)!
            let end = textView.position(from: start, offset: 1)!
            let tRange = textView.textRange(from: start, to: end)!
            let rect = textView.firstRect(for: tRange)
            path.append(UIBezierPath(rect: rect))
            paths.append(path.cgPath)
        }
        displayLink = CADisplayLink(target: self, selector: #selector(updateMaskPath))
        displayLink?.preferredFramesPerSecond = 10
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func startAnimation_label() {
        index = 0
        paths.removeAll()
        let path = UIBezierPath()
        for index in 0 ..< textLabel.text!.count {
            let rect = textLabel.boundingRectForCharacterRange(NSRange(location: index, length: 1))!
            path.append(UIBezierPath(rect: rect.integral))
            paths.append(path.cgPath)
        }
        displayLink = CADisplayLink(target: self, selector: #selector(updateMaskPath))
        displayLink?.preferredFramesPerSecond = 10
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc func updateMaskPath() {
        if index == paths.count {
            stopDisplayLink()
            return
        }
        self.textMaskView.shapeLayer.path = paths[index]
        index += 1
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func startTextViewAnimation(_ sender: Any) {
        guard let cell = collectionView.visibleCells.compactMap({ $0 as? TextCollectionCell}).first else { return }
        cell.startAnimation()
    }
    
    @IBAction func startLableAnimation(_ sender: Any) {
        guard let cell = collectionView.visibleCells.compactMap({ $0 as? TextLabelCollectionCell}).first else { return }
        cell.startAnimation()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextLabelCell", for: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Empty", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

