//
//  StringSimpleAttribute.swift
//  Mattermost
//
//  Created by Maxim Gubin on 07/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum StringAttributeType: Int {
    case link = 0
    case font = 5
    case string = 1
    case url = 3
    case color = 4
    case unknown = -1
}

@objc enum ColorType: Int {
    case commonMessage = 1
    case systemMessage = 2
    case hashtag = 3
    case mention = 4
    case mentionBackground = 5
    case link = 6
}

final class StringAttribute: Object {
    dynamic var type: StringAttributeType = .unknown
    dynamic var name: String?
    fileprivate dynamic var value: String?
    fileprivate dynamic var colorType: ColorType = .commonMessage
    fileprivate dynamic var fontSize: Float = 0
    
    var valueCache: AnyObject? {
        switch type {
        case .string:
            return self.value as AnyObject?
        case .link:
            return self.value as AnyObject?
        case .font:
            return UIFont(name: self.value!, size: CGFloat(self.fontSize))
        case .color:
            switch self.colorType {
                case .commonMessage:
                    return ColorBucket.commonMessageColor
                case .hashtag:
                    return ColorBucket.hashtagColor
                case .link:
                    return ColorBucket.linkColor
                case .mention:
                    return ColorBucket.mentionColor
                case .mentionBackground:
                    return ColorBucket.mentionBackgroundColor
                case .systemMessage:
                    return ColorBucket.systemMessageColor
            }
        
            default: return nil
        }
    }
   
    override class func ignoredProperties() -> [String] {
        return ["valueCache"]
    }
    
    func setValue(_ value: AnyObject, attributeName: String) {
        switch value {
            case is UIColor:
                self.setColorValue(value as! UIColor, attributeName: attributeName)
            break
            
            case is UIFont:
                self.setFontValue(value as! UIFont, attributeName: attributeName)
            break
                
            case is URL:
                self.setURLValue(value as! URL, attributeName: attributeName)
            break
            
            case is String:
                self.setStringValue(value as! String, attributeString: attributeName)
            break
            
            default : break
        }
    }
    func setStringValue(_ string: String, attributeString: String) {
        self.value = string
        self.name = attributeString
        self.type = .string
    }
    
    func setURLValue(_ URL: Foundation.URL, attributeName: String) {
        self.value = URL.absoluteString
        self.name = attributeName
        self.type = .link
    }
    
    func setFontValue(_ font: UIFont, attributeName: String) {
        self.value = font.fontName
        self.fontSize = Float(font.pointSize)
        self.name = attributeName
        self.type = .font
    }
    
    func setColorValue(_ color: UIColor, attributeName: String) {
        
        switch color {
            
            case ColorBucket.commonMessageColor:
                self.colorType = .commonMessage
            break
            
            case ColorBucket.systemMessageColor:
                self.colorType = .systemMessage
            break
            
            case ColorBucket.hashtagColor:
                self.colorType = .hashtag
            break
            
            case ColorBucket.mentionColor:
                self.colorType = .mention
            break
            
            case ColorBucket.mentionBackgroundColor:
                self.colorType = .mentionBackground
            break
            
            case ColorBucket.linkColor:
                self.colorType = .link
            break
            
            default:
            break
            
        }

        self.name = attributeName
        self.type = .color
    }

    
}
