//
//  BaseMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol BaseMappings: class {
    static func mapping() -> RKObjectMapping
    static func emptyResponseMapping() -> RKObjectMapping
    static func emptyMapping() -> RKObjectMapping
    static func requestMapping() -> RKObjectMapping
}

class BaseMappingsContainer: RKObjectMapping {
    //
}

// MARK: - Mappings
extension BaseMappingsContainer: BaseMappings  {
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary(["id" : CommonAttributes.identifier.rawValue])
        return mapping;
    }
    
    static func emptyResponseMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: NSNull.self)
    }
    
    static func emptyMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: self)
    }
    
    override class func requestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromDictionary([CommonAttributes.identifier.rawValue : "id"])
        return mapping;
    }
}