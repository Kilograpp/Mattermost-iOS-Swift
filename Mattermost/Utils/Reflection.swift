//
//  Reflection.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 12.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class Reflection {
    static func fetchNotNullValues(object:RealmObject) -> [String : AnyObject] {
        var result = [String : AnyObject]()
        let properties = object.objectSchema.properties
        for property in properties {
            let field = property.name
            if let value = object.valueForKey(property.name) {
                switch property.type {
                case .Bool:
                    break
                case .Array:
                    if (value as! ListBase).count != 0 {
                        result [field] = value
                    }
                    break
                default:
                    result [field] = value
                    break
                }
            }
        }
        return result
    }
}