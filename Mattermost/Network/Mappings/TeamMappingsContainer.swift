//
//  TeamMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
    static func initialLoadConfigMapping() -> RKObjectMapping
}

final class TeamMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return Team.self
    }
}

//MARK: - ResponseMappings
extension TeamMappingsContainer: ResponseMappings {
    override static func mapping() -> RKObjectMapping {
        let entityMapping = super.mapping()
        entityMapping.addAttributeMappingsFromDictionary(["display_name" : TeamAttributes.displayName.rawValue])
        entityMapping.addAttributeMappingsFromArray([TeamAttributes.name.rawValue])
        return entityMapping
    }
    static func initialLoadConfigMapping() -> RKObjectMapping {
        let entityMapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        entityMapping.addAttributeMappingsFromDictionary(["SiteName" : PreferencesAttributes.siteName.rawValue])
        return entityMapping
    }
}