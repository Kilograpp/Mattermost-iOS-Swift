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
    case Link = 0
    case Font = 5
    case String = 1
    case URL = 3
    case Color = 4
    case Unknown = -1
}

@objc enum ColorType: Int {
    case CommonMessage = 1
    case SystemMessage = 2
    case Hashtag = 3
    case Mention = 4
    case MentionBackground = 5
    case Link = 6
}

final class StringAttribute: Object {
    dynamic var type: StringAttributeType = .Unknown
    dynamic var name: String?
    private dynamic var value: String?
    private dynamic var colorType: ColorType = .CommonMessage
    private dynamic var fontSize: Float = 0
    
    var valueCache: AnyObject? {
        switch type {
        case .String:
            return self.value
        case .Link:
            return self.value
        case .Font:
            return UIFont(name: self.value!, size: CGFloat(self.fontSize))
        case .Color:
            switch self.colorType {
                case .CommonMessage:
                    return ColorBucket.commonMessageColor
                case .Hashtag:
                    return ColorBucket.hashtagColor
                case .Link:
                    return ColorBucket.linkColor
                case .Mention:
                    return ColorBucket.mentionColor
                case .MentionBackground:
                    return ColorBucket.mentionBackgroundColor
                case .SystemMessage:
                    return ColorBucket.systemMessageColor
            }
        
            default: return nil
        }
    }
   
    override class func ignoredProperties() -> [String] {
        return ["valueCache"]
    }
    
    func setValue(value: AnyObject, attributeName: String) {
        switch value {
            case is UIColor:
                self.setColorValue(value as! UIColor, attributeName: attributeName)
            break
            
            case is UIFont:
                self.setFontValue(value as! UIFont, attributeName: attributeName)
            break
                
            case is NSURL:
                self.setURLValue(value as! NSURL, attributeName: attributeName)
            break
            
            case is String:
                self.setStringValue(value as! String, attributeString: attributeName)
            break
            
            default : break
        }
    }
    func setStringValue(string: String, attributeString: String) {
        self.value = string
        self.name = attributeString
        self.type = .String
    }
    
    func setURLValue(URL: NSURL, attributeName: String) {
        self.value = URL.absoluteString
        self.name = attributeName
        self.type = .Link
    }
    
    func setFontValue(font: UIFont, attributeName: String) {
        self.value = font.fontName
        self.fontSize = Float(font.pointSize)
        self.name = attributeName
        self.type = .Font
    }
    
    func setColorValue(color: UIColor, attributeName: String) {
        
        switch color {
            
            case ColorBucket.commonMessageColor:
                self.colorType = .CommonMessage
            break
            
            case ColorBucket.systemMessageColor:
                self.colorType = .SystemMessage
            break
            
            case ColorBucket.hashtagColor:
                self.colorType = .Hashtag
            break
            
            case ColorBucket.mentionColor:
                self.colorType = .Mention
            break
            
            case ColorBucket.mentionBackgroundColor:
                self.colorType = .MentionBackground
            break
            
            case ColorBucket.linkColor:
                self.colorType = .Link
            break
            
            default:
                "❤️"
            break
            
        }

        self.name = attributeName
        self.type = .Color
    }

    
}