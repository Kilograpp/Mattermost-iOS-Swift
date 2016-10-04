//
//  MessageLabel.swift
//  Mattermost
//
//  Created by Maxim Gubin on 07/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Delegate {
    var onMentionTap: ((_ username: String) -> Void)? {get set}
    var onUrlTap: ((_ url: URL) -> Void)? {get set}
    var onHashTagTap: ((_ hashTag: String) -> Void)? {get set}
    var onPhoneTap: ((_ phone: String) -> Void)? {get set}
    var onEmailTap: ((_ email: String) -> Void)? {get set}
}

final class MessageLabel: AttributedLabel, Delegate {

    var onMentionTap: ((_ username: String) -> Void)?
    var onUrlTap: ((_ url: URL) -> Void)?
    var onHashTagTap: ((_ hashTag: String) -> Void)?
    var onPhoneTap: ((_ phone: String) -> Void)?
    var onEmailTap: ((_ email: String) -> Void)?
    
    func handleTouch(_ touch: UITouch){
        let indexOfCharacter = self.characterIndexForTouch(touch)
        
        if let username = textStorage!.mentionAtIndex(indexOfCharacter) {
            self.onMentionTap?(username)
            return
        }
        
        if let hashTag = textStorage!.hashTagAtIndex(indexOfCharacter) {
            self.onHashTagTap?(hashTag)
            return
        }
        
        if let email = textStorage!.emailAtIndex(indexOfCharacter) {
            self.onEmailTap?(email)
            return
        }
        
        if let url = textStorage!.URLAtIndex(indexOfCharacter) {
            self.onUrlTap?(url)
            return
        }
        
        if let phone = textStorage!.phoneAtIndex(indexOfCharacter) {
            self.onPhoneTap?(phone)
            return
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
        super.touchesEnded(touches, with: event)
    }
    
    fileprivate func characterIndexForTouch(_ touch: UITouch) -> Int {
        guard let storage = self.textStorage else { return 0 }
        
        let locationOfTouch = touch.location(in: self)
        self.textContainer.size = self.bounds.size
//        storage.setAttributedString(self.attributedText!)
        return self.layoutManager.glyphIndex(for: locationOfTouch, in: self.textContainer)
    }

}

extension MessageLabel : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
