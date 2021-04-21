//
//  TextCollectionCell.swift
//  TextShowedAnimation
//
//  Created by MOMO on 2021/4/21.
//

import UIKit

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
//        let startTime = DispatchTime.now()
//        let _start = CFAbsoluteTimeGetCurrent()
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
//
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
