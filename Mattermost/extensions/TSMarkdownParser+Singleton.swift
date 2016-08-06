//
//  TSMarkdownParser+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import TSMarkdownParser

extension TSMarkdownParser {
    @nonobjc static let sharedInstance = TSMarkdownParser.customParser()
    
    private static func customParser() -> TSMarkdownParser {
        let defaultParser = TSMarkdownParser()
        defaultParser.setupAttributes()
        defaultParser.configureDefaultInnerParsers()
        return defaultParser
    }
    
    private static func addAttributes(attributesArray: [[String : AnyObject]], atIndex level: UInt, toString attributedString: NSMutableAttributedString, range: NSRange) {
        guard attributesArray.count != 0 else {
            return
        }
        let index = Int(level)
        let attributes = index < attributesArray.count ? attributesArray[index] : attributesArray.last!
        attributedString.addAttributes(attributes, range: range)
    }
}

extension TSMarkdownParser {
    private func setupAttributes() -> Void {
        self.setupSettings()
        self.setupDefaultAttributes()
        self.setupHeaderAttributes()
        self.setupEmphasisAttributes()
    }
    
    private func setupSettings() -> Void {
        self.skipLinkAttribute = false
    }
    
    private func setupDefaultAttributes() -> Void {
        self.defaultAttributes = [NSFontAttributeName : FontBucket.messageFont,
                                  NSForegroundColorAttributeName : ColorBucket.blackColor]
    }
    
    private func setupHeaderAttributes() -> Void {
        let headerAttributes = NSMutableArray()
        
        for index in 0...6 {
            let attributes = [
                NSFontAttributeName : FontBucket.self.semiboldFontOfSize(CGFloat(26 - 2 * index)),
                NSForegroundColorAttributeName : ColorBucket.blackColor
            ]
            headerAttributes.addObject(attributes)
        }
        
        self.headerAttributes = headerAttributes.copy() as! [[String : AnyObject]]
    }
    
    private func setupEmphasisAttributes() {
        self.emphasisAttributes = [
            NSFontAttributeName            : FontBucket.emphasisFont,
            NSForegroundColorAttributeName : ColorBucket.blackColor
        ]
    }
    
    private func configureDefaultInnerParsers() {
        self.addCodeEscapingParsing()
        self.addEscapingParsing()
        self.addHeaderParsingWithMaxLevel(0, leadFormattingBlock: { (attributedString, range, level) in
            attributedString.deleteCharactersInRange(range)
        }) { [unowned self] (attributedString, range, level) in
            TSMarkdownParser.addAttributes(self.headerAttributes, atIndex: level-1, toString: attributedString, range: range)
        }
        
        self.addListParsingWithMaxLevel(0, leadFormattingBlock: { (attributedString, range, level) in
            let listString = NSMutableString()
            for _ in level.stride(to: 0, by: -1) {
                listString.appendString("  ")
            }
            listString.appendString("• ")
            attributedString.replaceCharactersInRange(range, withString: listString as String)
        }) { [unowned self] (attributedString, range, level) in
            TSMarkdownParser.addAttributes(self.listAttributes, atIndex: level-1, toString: attributedString, range: range)
        }
        
        self.addQuoteParsingWithMaxLevel(0, leadFormattingBlock: { (attributedString, range, level) in
            let quoteString = NSMutableString()
            for _ in level.stride(through: 0, by: -1) {
                quoteString.appendString("\t")
            }
            attributedString.replaceCharactersInRange(range, withString: quoteString as String)
        }) { [unowned self] (attributedString, range, level) in
            TSMarkdownParser.addAttributes(self.quoteAttributes, atIndex: level-1, toString: attributedString, range: range)
        }
        
        self.addLinkParsingWithLinkFormattingBlock { [unowned self] (attributedString, range, link) in
            if !self.skipLinkAttribute {
                let preparedLink = link?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                if let url = NSURL(string: preparedLink ?? StringUtils.emptyString()) {
                    attributedString.addAttribute(NSLinkAttributeName, value: url, range: range)
                }
            }
            attributedString.addAttributes(self.linkAttributes, range: range)
        }
        
        self.addLinkDetectionWithLinkFormattingBlock { [unowned self] (attributedString, range, link) in
            if !self.skipLinkAttribute {
                if let url = NSURL(string: link ?? StringUtils.emptyString()) {
                    attributedString.addAttribute(NSLinkAttributeName, value: url, range: range)
                }
            }
            attributedString.addAttributes(self.linkAttributes, range: range)
        }
        
        let emphasisExpression = try! NSRegularExpression(pattern: "(?<!\\S)(_)(.*?)(_(?!\\S))", options: .CaseInsensitive)
        self.addParsingRuleWithRegularExpression(emphasisExpression) { [unowned self] (match, attributedString) in
            attributedString.deleteCharactersInRange(match.rangeAtIndex(3))
            attributedString.addAttributes(self.emphasisAttributes, range: match.rangeAtIndex(2))
            attributedString.deleteCharactersInRange(match.rangeAtIndex(1))
            
        }
        
        self.addStrongParsingWithFormattingBlock { [unowned self] (attributedString, range) in
            attributedString.addAttributes(self.strongAttributes, range: range)
        }
        
        self.addCodeUnescapingParsingWithFormattingBlock { [unowned self] (attributedString, range) in
            attributedString.addAttributes(self.monospaceAttributes, range: range)
        }
        
        self.addUnescapingParsing()
        
        let mentionExpression = try! NSRegularExpression(pattern: "@\\w\\S*\\b", options: .CaseInsensitive)
        self.addParsingRuleWithRegularExpression(mentionExpression) { (match, attributedString) in
            let range = NSMakeRange(match.range.location+1, match.range.length-1)
            let name = (attributedString.string as NSString).substringWithRange(range)
            
            var attributes = [NSForegroundColorAttributeName : ColorBucket.blueColor]
            
            if name == DataManager.sharedInstance.currentUser?.username {
                attributes[NSBackgroundColorAttributeName] =  UIColor.yellowColor()
            }
  
            attributedString.addAttributes(attributes, range: match.range)
        }
    }
    
}