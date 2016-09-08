//
//  BaseMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import RestKit

protocol CommonMappings: class {
    static func mapping() -> RKObjectMapping
    static func emptyResponseMapping() -> RKObjectMapping
    static func emptyMapping() -> RKObjectMapping
    static func requestMapping() -> RKObjectMapping
}

protocol ClassForMapping {
    static var classForMapping : AnyClass! { get }
}

class BaseMappingsContainer: RKObjectMapping {

//MARK: - CommonMappings
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self.classForMapping)
        mapping.addAttributeMappingsFromDictionary(["id" : CommonAttributes.identifier.rawValue])
        return mapping;
    }
    
    static func emptyResponseMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: NSNull.self)
    }
    
    static func emptyMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: self.classForMapping)
    }
    
   override class func requestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromDictionary([CommonAttributes.identifier.rawValue : "id"])
        return mapping;
    }
}

//MARK: - ClassForMapping
extension BaseMappingsContainer : ClassForMapping {
    class var classForMapping : AnyClass! {
        return RealmObject.self
    }
}

