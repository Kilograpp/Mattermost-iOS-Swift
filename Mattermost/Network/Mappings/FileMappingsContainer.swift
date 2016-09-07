//
//  FileMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func simplifiedMapping() -> RKObjectMapping
    static func uploadMapping() -> RKObjectMapping
}

final class FileMappingsContainer: BaseMappingsContainer {
    //
}

extension FileMappingsContainer: ResponseMappings {
    static func simplifiedMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: FileAttributes.rawLink.rawValue))
        return mapping
    }
    
    static func uploadMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(withClass: NSMutableDictionary.self)
        mapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: FileAttributes.rawLink.rawValue))
        
        return mapping
    }
}