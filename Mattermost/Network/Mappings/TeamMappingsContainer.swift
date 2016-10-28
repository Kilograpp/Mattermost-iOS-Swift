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
    static func invitationMapping() -> RKObjectMapping
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
        entityMapping.addAttributeMappings(from: ["display_name" : TeamAttributes.displayName.rawValue])
        entityMapping.addAttributeMappings(from: [TeamAttributes.name.rawValue])
        return entityMapping
    }
    static func initialLoadConfigMapping() -> RKObjectMapping {
        let entityMapping = RKObjectMapping(for: NSMutableDictionary.self)
        entityMapping?.addAttributeMappings(from: ["SiteName" : PreferencesAttributes.siteName.rawValue])
        return entityMapping!
    }
    static func invitationMapping() -> RKObjectMapping {
        let entityMapping = RKObjectMapping(for: NSMutableDictionary.self)
        return entityMapping!
    }
}
