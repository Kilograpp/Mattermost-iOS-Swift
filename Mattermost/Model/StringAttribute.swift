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

final class StringAttribute: Object {
    dynamic var type: StringAttributeType = .Unknown
    dynamic var name: String?
    dynamic var value: String?
    private dynamic var float1: Float = 0
    private dynamic var float2: Float = 0
    private dynamic var float3: Float = 0
    var valueCache: AnyObject? {
        switch type {
        case .String:
            return self.value
        case .Link:
            return self.value
        case .Font:
            return UIFont(name: self.value!, size: CGFloat(self.float1))
        case .Color:
            return UIColor(red: CGFloat(self.float1), green: CGFloat(self.float2), blue: CGFloat(self.float3), alpha: 1)
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
        self.float1 = Float(font.pointSize)
        self.name = attributeName
        self.type = .Font
    }
    
    func setColorValue(color: UIColor, attributeName: String) {
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        self.float1 = Float(red)
        self.float2 = Float(green)
        self.float3 = Float(blue)
        self.name = attributeName
        self.type = .Color
    }

    
}