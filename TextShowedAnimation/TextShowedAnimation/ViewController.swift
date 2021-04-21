//
//  ViewController.swift
//  TextShowedAnimation
//
//  Created by MOMO on 2021/4/19.
//

import UIKit


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
    
    var animator: TextAnimator!
    var cursorImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.lineHeightMultiple = 1
        textLabel.attributedText = NSAttributedString(string: textLabel.text!, attributes: [.font: textLabel.font!, .link: "http://www.google.com", .paragraphStyle: paragraphStyle])
        
        animator = TextAnimator.showText(textLabel.attributedText!, on: textLabel, cursor: UIImage(named: "cursor"))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animator.stopAnimation()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            animator.stopAnimation()
        }
    }
    
    func startAnimation() {
        animator.startAnimation()
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

