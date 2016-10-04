//
//  Attachment.swift
//  Mattermost
//
//  Created by Maxim Gubin on 06/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

enum AttachmentAttributes: String {
    case color = "color"
    case pretext = "pretext"
    case attributedPretext = "attributedPretext"
    case fallback = "fallback"
    case attributedFallback = "attributedFallback"
    case text = "text"
    case attributedText = "attributedText"
}

enum AttachmentRelationship: String {
    case fields = "fields"
}

final class Attachment: RealmObject {
    dynamic var color: String?
    dynamic var text: String? {
        didSet {
            computeAttributedText()
            computeAttributedTextData()
        }
    }
    dynamic var pretext: String? {
        didSet {
            computeAttributedPretext()
            computeAttributedPretextData()
        }
    }
    dynamic var fallback: String? {
        didSet {
            computeAttributedFallback()
            computeAttributedFallbackData()
        }
    }
    
    fileprivate dynamic var _attributedTextData: RealmAttributedString?
    fileprivate dynamic var _attributedFallbackData: RealmAttributedString?
    fileprivate dynamic var _attributedPretextData: RealmAttributedString?
    
    lazy var attributedPretext: NSAttributedString? = {
        return self._attributedPretextData?.attributedString
    }()
    lazy var attributedFallback: NSAttributedString? = {
        return self._attributedFallbackData?.attributedString
    }()
    lazy var attributedText: NSAttributedString? = {
        return self._attributedTextData?.attributedString
    }()
        
    let fields = List<AttachmentField>()
    
    
    override class func ignoredProperties() -> [String] {
        return [
            AttachmentAttributes.attributedPretext.rawValue,
            AttachmentAttributes.attributedFallback.rawValue,
            AttachmentAttributes.attributedText.rawValue
        ]
    }
}

private protocol Computations : class {
    func computeAttributedFallback()
    func computeAttributedText()
    func computeAttributedPretext()
    func computeAttributedFallbackData()
    func computeAttributedPretextData()
    func computeAttributedTextData()
}

extension Attachment: Computations {
    fileprivate func computeAttributedFallback() {
        self.attributedFallback = self.fallback?.markdownAttributedString()
    }
    fileprivate func computeAttributedText() {
        self.attributedText = self.text?.markdownAttributedString()
    }
    fileprivate func computeAttributedPretext() {
        self.attributedPretext = self.pretext?.markdownAttributedString()
    }
    fileprivate func computeAttributedFallbackData() {
        self._attributedFallbackData = RealmAttributedString(attributedString: self.attributedFallback)
    }
    fileprivate func computeAttributedPretextData() {
        self._attributedPretextData = RealmAttributedString(attributedString: self.attributedPretext)
    }
    fileprivate func computeAttributedTextData() {
        self._attributedTextData = RealmAttributedString(attributedString: self.attributedText)
    }
}
