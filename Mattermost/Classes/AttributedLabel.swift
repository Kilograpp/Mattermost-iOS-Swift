//
//  AttributedLabel.swift
//  AttributedLabel
//
//  Created by Kyohei Ito on 2015/07/17.
//  Copyright © 2015年 Kyohei Ito. All rights reserved.
//

import UIKit

class AttributedLabel: UILabel {
    
    override var frame: CGRect {
        didSet {
            self.textContainer.size = self.frame.size
        }
    }
    
    /// default is `0`.
    override var numberOfLines: Int {
        didSet {
            self.textContainer.maximumNumberOfLines = self.numberOfLines
            setNeedsDisplay()
        }
    }

    /// `lineFragmentPadding` of `NSTextContainer`. default is `0`.
    var padding: CGFloat = 0 {
        didSet {
            self.textContainer.lineFragmentPadding = self.padding
            setNeedsDisplay()
        }
    }

    /// default is `ByTruncatingTail`.
    override var lineBreakMode: NSLineBreakMode  {
        didSet {
            self.textContainer.lineBreakMode = self.lineBreakMode
            setNeedsDisplay()
        }
    }


    
    var textStorage: NSTextStorage? = NSTextStorage() {
        didSet {
            self.layoutManager.textStorage = self.textStorage
        }
    }
    var textContainer = NSTextContainer()
    var layoutManager = NSLayoutManager()
    
    
    private func setup() {
        opaque = true
        contentMode = .Redraw
        self.textContainer = self.textContainer(self.bounds.size)
        self.layoutManager = self.layoutManager(self.textContainer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func setNeedsDisplay() {
        if NSThread.isMainThread() {
            super.setNeedsDisplay()
        }
    }
    
    override func drawTextInRect(rect: CGRect) {
        guard let storage = self.textStorage else { return }
        
        let range = NSRange(location: 0, length: storage.length)

        layoutManager.drawBackgroundForGlyphRange(range, atPoint: CGPointZero)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: CGPointZero)

    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        guard self.attributedText != nil else {
            return super.sizeThatFits(size)
        }
        
        self.textContainer.size = size
        let frame = layoutManager.usedRectForTextContainer(textContainer)
        return CGRectIntegral(frame).size
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        frame.size = sizeThatFits(CGSize(width: bounds.width, height: CGFloat.max))
    }
    
    private func textContainer(size: CGSize) -> NSTextContainer {
        let container = NSTextContainer(size: size)
        container.lineBreakMode = lineBreakMode
        container.lineFragmentPadding = padding
        container.maximumNumberOfLines = numberOfLines
        return container
    }
    
    private func textStorage(attributedString: NSAttributedString) -> NSTextStorage {
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(self.layoutManager)
        return textStorage
    }
    
    private func layoutManager(container: NSTextContainer) -> NSLayoutManager {
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)
        layoutManager.allowsNonContiguousLayout = true
    
        return layoutManager
    }
    
}
