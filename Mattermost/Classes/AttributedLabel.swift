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
            self.setNeedsDisplay()
        }
    }
    var textContainer = NSTextContainer()
    var layoutManager = NSLayoutManager()
    
    
    fileprivate func setup() {
        isOpaque = true
        contentMode = .redraw
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
        if Thread.isMainThread {
            super.setNeedsDisplay()
        }
    }
    
    override func drawText(in rect: CGRect) {
        guard let storage = self.textStorage else { return }
        
        let range = NSRange(location: 0, length: storage.length)

        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint.zero)
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint.zero)

    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard self.attributedText != nil else {
            return super.sizeThatFits(size)
        }
        
        self.textContainer.size = size
        let frame = layoutManager.usedRect(for: textContainer)
        return frame.integral.size
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        frame.size = sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    fileprivate func textContainer(_ size: CGSize) -> NSTextContainer {
        let container = NSTextContainer(size: size)
        container.lineBreakMode = lineBreakMode
        container.lineFragmentPadding = padding
        container.maximumNumberOfLines = numberOfLines
        return container
    }
    
    fileprivate func textStorage(_ attributedString: NSAttributedString) -> NSTextStorage {
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(self.layoutManager)
        return textStorage
    }
    
    fileprivate func layoutManager(_ container: NSTextContainer) -> NSLayoutManager {
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)
        layoutManager.allowsNonContiguousLayout = true
    
        return layoutManager
    }
    
}
