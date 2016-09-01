//
//  RealmAttributedString.swift
//  Mattermost
//
//  Created by Maxim Gubin on 07/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmAttributedString: Object {
    dynamic var string: String?
    
    let parameters = List<StringParameter>()
    
    var attributedString: NSTextStorage? {
        
        guard let string = self.string else {
            return nil
        }
        
        let attributedString = NSTextStorage(string: string)
        attributedString.beginEditing()
        self.parameters.forEach { (parameter) in
            
            let range = parameter.range
            parameter.attributes.forEach({ (attribute) in
                
                if attribute.type != .Unknown {
                    attributedString.addAttribute(attribute.name!, value: attribute.valueCache!, range: range)
                }
            })
        }
        attributedString.endEditing()
        
        return attributedString
    }
    
    convenience init?(attributedString: NSAttributedString?) {
        guard let attributedString = attributedString else {
            return nil
        }
        
        self.init()
        
        self.string = attributedString.string
        
        attributedString.enumerateAttributesInRange(NSMakeRange(0, attributedString.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (attributes, range, stop) in
            
            let parameter = StringParameter()
            parameter.range = range
            
            attributes.forEach({ (key, value) in
                let attribute = StringAttribute()
                attribute.setValue(value, attributeName: key)
                parameter.attributes.append(attribute)
            })
            
            self.parameters.append(parameter)
            
        }

    }
    
    
    override class func ignoredProperties() -> [String] {
        return ["attributedString"]
    }
}