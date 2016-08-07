//
//  MessageLabel.swift
//  Mattermost
//
//  Created by Maxim Gubin on 07/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Delegate {
    var onMentionTap: ((username: String) -> Void)? {get set}
    var onUrlTap: ((url: NSURL) -> Void)? {get set}
    var onHashTagTap: ((hashTag: String) -> Void)? {get set}
}

final class MessageLabel: UILabel, Delegate {

    var onMentionTap: ((username: String) -> Void)?
    var onUrlTap: ((url: NSURL) -> Void)?
    var onHashTagTap: ((hashTag: String) -> Void)?
    
    private var textStorage = NSTextStorage()
    private var textContainer = NSTextContainer()
    private var layoutManager = NSLayoutManager()
    
    
    override var lineBreakMode: NSLineBreakMode {
        didSet { self.textContainer.lineBreakMode = self.lineBreakMode }
    }
    
    override var numberOfLines: Int {
        didSet { self.textContainer.maximumNumberOfLines = self.numberOfLines }
    }


    private func setup() {
        self.userInteractionEnabled = true
        self.textStorage.addLayoutManager(self.layoutManager)
        self.layoutManager.addTextContainer(self.textContainer)
        self.textContainer.lineFragmentPadding = 0
        self.textContainer.lineBreakMode = self.lineBreakMode
        self.textContainer.maximumNumberOfLines = self.numberOfLines
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    
    func handleTouch(touch: UITouch){

        let indexOfCharacter = self.characterIndexForTouch(touch)
        
        if let url = self.attributedText?.URLAtIndex(indexOfCharacter) {
            self.onUrlTap?(url: url)
            return
        }
        
        if let username = self.attributedText?.mentionAtIndex(indexOfCharacter) {
            self.onMentionTap?(username: username)
            return
        }
        
        if let hashTag = self.attributedText?.hashTagAtIndex(indexOfCharacter) {
            self.onHashTagTap?(hashTag: hashTag)
            return
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
        super.touchesEnded(touches, withEvent: event)
    }
    
    private func characterIndexForTouch(touch: UITouch) -> Int {
        let locationOfTouch = touch.locationInView(self)
        self.textContainer.size = self.bounds.size
        self.textStorage.setAttributedString(self.attributedText!)
        return self.layoutManager.glyphIndexForPoint(locationOfTouch, inTextContainer: self.textContainer)
    }

}

extension MessageLabel : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}