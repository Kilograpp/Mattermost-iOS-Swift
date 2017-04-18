//
//  TSMarkdownParser+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import TSMarkdownParser
import RealmSwift
import Emoji

extension TSMarkdownParser {
    @nonobjc static let sharedInstance = TSMarkdownParser.customParser()
    
    fileprivate static func customParser() -> TSMarkdownParser {
        let defaultParser = TSMarkdownParser()
        defaultParser.setupAttributes()
        defaultParser.setupDefaultParsers()
        return defaultParser
    }
    
    fileprivate static func addAttributes(_ attributesArray: [[String : AnyObject]], atIndex level: UInt, toString attributedString: NSMutableAttributedString, range: NSRange) {
        guard attributesArray.count != 0 else {
            return
        }
        let index = Int(level)
        let attributes = index < attributesArray.count ? attributesArray[index] : attributesArray.last!
        attributedString.addAttributes(attributes, range: range)
    }
}

// MARK: - Setup
extension TSMarkdownParser {
    fileprivate func setupAttributes() -> Void {
        self.setupSettings()
        self.setupDefaultAttributes()
        self.setupHeaderAttributes()
        self.setupEmphasisAttributes()
    }
    
    fileprivate func setupDefaultParsers() {
        self.addCodeEscapingParsing()
        self.addEscapingParsing()
        self.addHeaderParsing()
        self.addListParsing()
        self.addQuoteParsing()
        self.addLinkParsing()
        self.addEmphasisParsing()
        self.addStrongParsing()
        self.addCodeUnescapingParsing()
        self.addUnescapingParsing()
        self.addMentionParsing()
        self.addHashtagParsing()
        self.addPhoneParsing()
        self.addEmailParsing()
        self.addEmojiParsing()
    }
    
    fileprivate func setupSettings() -> Void {
        self.skipLinkAttribute = false
    }
    
    fileprivate func setupDefaultAttributes() -> Void {
        self.defaultAttributes = [NSFontAttributeName : FontBucket.messageFont,
                                  NSForegroundColorAttributeName : ColorBucket.commonMessageColor]
    }
    
    fileprivate func setupHeaderAttributes() -> Void {
        let headerAttributes = NSMutableArray()
        
        for index in 0...6 {
            let attributes = [
                NSFontAttributeName : FontBucket.self.semiboldFontOfSize(CGFloat(26 - 2 * index)),
                NSForegroundColorAttributeName : ColorBucket.commonMessageColor
            ]
            headerAttributes.add(attributes)
        }
        
        self.headerAttributes = headerAttributes.copy() as! [[String : AnyObject]]
    }
    
    fileprivate func setupEmphasisAttributes() {
        self.emphasisAttributes = [
            NSFontAttributeName            : FontBucket.emphasisFont,
            NSForegroundColorAttributeName : ColorBucket.commonMessageColor
        ]
    }
}

// MARK: - Parsers
extension TSMarkdownParser {
    fileprivate func addHeaderParsing() {
        self.addHeaderParsing(withMaxLevel: 0, leadFormattingBlock: { (attributedString, range, level) in
            attributedString.deleteCharacters(in: range)
        }) { [unowned self] (attributedString, range, level) in
            TSMarkdownParser.addAttributes(self.headerAttributes as [[String : AnyObject]], atIndex: level-1, toString: attributedString, range: range)
        }
    }
    
    fileprivate func addListParsing() {
        self.addListParsing(withMaxLevel: 0, leadFormattingBlock: { (attributedString, range, level) in
            let listString = NSMutableString()
            for _ in stride(from: level, to: 0, by: -1) {
                listString.append("  ")
            }
            listString.append("• ")
            attributedString.replaceCharacters(in: range, with: listString as String)
        }) { [unowned self] (attributedString, range, level) in
            TSMarkdownParser.addAttributes(self.listAttributes as [[String : AnyObject]], atIndex: level-1, toString: attributedString, range: range)
        }
    }
    
    fileprivate func addQuoteParsing() {
        self.addQuoteParsing(withMaxLevel: 0, leadFormattingBlock: { (attributedString, range, level) in
            let quoteString = NSMutableString()
            for _ in stride(from: level, through: 0, by: -1) {
                quoteString.append("\t")
            }
            attributedString.replaceCharacters(in: range, with: quoteString as String)
        }) { [unowned self] (attributedString, range, level) in
            TSMarkdownParser.addAttributes(self.quoteAttributes as [[String : AnyObject]], atIndex: level-1, toString: attributedString, range: range)
        }
    }
    
    fileprivate func addLinkParsing() {
        self.addLinkParsing { [unowned self] (attributedString, range, link) in
            if !self.skipLinkAttribute {
                let preparedLink = link?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                if let url = URL(string: preparedLink ?? StringUtils.emptyString()) {
                    attributedString.addAttribute(NSLinkAttributeName, value: url, range: range)
                    
                }
            }
            attributedString.addAttributes(self.linkAttributes, range: range)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: ColorBucket.linkColor, range: range)
        }
        
        self.addLinkDetection { [unowned self] (attributedString, range, link) in
            if !self.skipLinkAttribute {
                if let url = URL(string: link ?? StringUtils.emptyString()) {
                    attributedString.addAttribute(NSLinkAttributeName, value: url, range: range)
                }
            }
            attributedString.addAttributes(self.linkAttributes, range: range)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: ColorBucket.linkColor, range: range)
        }
    }
    
    fileprivate func addEmailParsing() {
        let pattern = "([a-zA-Z]{1,256}@[a-zA-Z0-9]{0,64}.[a-zA-Z0-9]{0,25})"
        let emailExpression = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        self.addParsingRule(with: emailExpression) { (match, attributedString) in
            let range = NSMakeRange(match.range.location, match.range.length)
            let email = (attributedString.string as NSString).substring(with: range)
            
            let attributes = [NSForegroundColorAttributeName : ColorBucket.linkColor]
            attributedString.addAttribute(Constants.StringAttributes.Email, value: email, range: match.range)
            attributedString.addAttributes(attributes, range: match.range)
        }
        
    }
    
    fileprivate func addPhoneParsing() {
        let pattern = "(\\b[0-9]{7,13}\\b)"
        let phoneExpression = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        self.addParsingRule(with: phoneExpression) { (match, attributedString) in
            var range = NSMakeRange(match.range.location, match.range.length)
            
            if (Int(attributedString.string[match.range.location]) == nil) {
                range.location += 1
                range.length -= 1
            }
            
            if (Int(attributedString.string[match.range.location + match.range.length - 1]) == nil) {
                range.length -= 1
            }
            
            let phone = (attributedString.string as NSString).substring(with: range)
 
            let attributes = [NSForegroundColorAttributeName : ColorBucket.linkColor]
            attributedString.addAttribute(Constants.StringAttributes.Phone, value: phone, range: range)
            attributedString.addAttributes(attributes, range: range)
        }
        
    }
    
    fileprivate func addCodeUnescapingParsing() {
        self.addCodeUnescapingParsing { [unowned self] (attributedString, range) in
            attributedString.addAttributes(self.monospaceAttributes, range: range)
        }
    }
    
    fileprivate func addHashtagParsing() {
        let hashtagExpression = try! NSRegularExpression(pattern: "(?:(?<=\\s)|^)#(\\w*[A-Za-z_]+\\w*)", options: .caseInsensitive)
        self.addParsingRule(with: hashtagExpression) { (match, attributedString) in
            let range = NSMakeRange(match.range.location+1, match.range.length-1)
            let hashTag = (attributedString.string as NSString).substring(with: range)
            
            let attributes = [NSForegroundColorAttributeName : ColorBucket.hashtagColor]
            
            attributedString.addAttribute(Constants.StringAttributes.HashTag, value: hashTag, range: match.range)
            attributedString.addAttributes(attributes, range: match.range)
        }
    }
    
    fileprivate func addMentionParsing() {
        let mentionExpression = try! NSRegularExpression(pattern: "@\\w\\S*\\b", options: .caseInsensitive)
        self.addParsingRule(with: mentionExpression) { (match, attributedString) in
            let range = NSMakeRange(match.range.location+1, match.range.length-1)
            let name = (attributedString.string as NSString).substring(with: range)
            
            guard try! Realm().objects(User.self).filter("%K == %@", UserAttributes.username.rawValue, name).count > 0 ||
                name == "all" || name == "channel" else {
                    return
            }
            
            var attributes = [NSForegroundColorAttributeName : ColorBucket.mentionColor]
            
            if name == DataManager.sharedInstance.currentUser?.username || name == "all" || name == "channel" {
                attributes[NSBackgroundColorAttributeName] =  ColorBucket.mentionBackgroundColor
                
            }
            attributedString.addAttribute(Constants.StringAttributes.Mention, value: name, range: match.range)
            attributedString.addAttributes(attributes, range: match.range)
        }
        
    }
    
    fileprivate func addStrongParsing() {
        self.addStrongParsing { [unowned self] (attributedString, range) in
            attributedString.addAttributes(self.strongAttributes, range: range)
        }
    }
    
    fileprivate func addEmphasisParsing() {
        let emphasisExpression = try! NSRegularExpression(pattern: "(?<!\\S)(_)(.*?)(_(?!\\S))", options: .caseInsensitive)
        self.addParsingRule(with: emphasisExpression) { [unowned self] (match, attributedString) in
            attributedString.deleteCharacters(in: match.rangeAt(3))
            attributedString.addAttributes(self.emphasisAttributes, range: match.rangeAt(2))
            attributedString.deleteCharacters(in: match.rangeAt(1))
            
        }
    }
    
    fileprivate func addEmojiParsing() {
        let emojiExpression = try! NSRegularExpression(pattern: "(?:(?<=\\s)|^):(\\w*[A-Za-z_]+\\w*):", options: .caseInsensitive)
        self.addParsingRule(with: emojiExpression) { (match, attributedString) in
            let range = NSMakeRange(match.range.location, match.range.length)
            let emoji = (attributedString.string as NSString).substring(with: range)
            
            attributedString.replaceCharacters(in: range, with: emoji.emojiUnescapedString)
        }
    }
    
}
