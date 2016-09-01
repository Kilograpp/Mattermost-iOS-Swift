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

final class MessageLabel: AttributedLabel, Delegate {

    var onMentionTap: ((username: String) -> Void)?
    var onUrlTap: ((url: NSURL) -> Void)?
    var onHashTagTap: ((hashTag: String) -> Void)?

    
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
        guard let storage = self.textStorage else { return 0 }
        
        let locationOfTouch = touch.locationInView(self)
        self.textContainer.size = self.bounds.size
        storage.setAttributedString(self.attributedText!)
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