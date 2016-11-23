//
//  Reflection.swift
//  Mattermost
//
//  Created by Владислав on 16.11.16.
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
            if let value = object.value(forKey: property.name) {
                switch property.type {
                case .bool:
                    break
                case .array:
                    if (value as! ListBase).count != 0 {
                        result [field] = value as AnyObject?
                    }
                    break
                default:
                    result [field] = value as AnyObject?
                    break
                }
            }
        }
        return result
    }
}
