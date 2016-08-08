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
    
    func attributedString() -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: self.string!)
        attributedString.beginEditing()
        self.parameters.forEach { (parameter) in
            
            let range = parameter.range!
            parameter.attributes.forEach({ (attribute) in
                
                if attribute.type != .Unknown {
                    attribute.computeValueCache()
                    attributedString.addAttribute(attribute.name!, value: attribute.valueCache!, range: range)
                }
            })
        }
        attributedString.endEditing()
        
        return attributedString
    }
    
    static func instanceWithAttributeString(attributedString: NSAttributedString) -> RealmAttributedString {
        
        let realmAttributeString = RealmAttributedString()
        realmAttributeString.string = attributedString.string
        
        attributedString.enumerateAttributesInRange(NSMakeRange(0, attributedString.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (attributes, range, stop) in

            let parameter = StringParameter()
            parameter.range = range
            
            attributes.forEach({ (key, value) in
                let attribute = StringAttribute()
                attribute.setValue(value, attributeName: key)
                parameter.attributes.append(attribute)
            })
            
            realmAttributeString.parameters.append(parameter)
            
        }
        return realmAttributeString
    }
}