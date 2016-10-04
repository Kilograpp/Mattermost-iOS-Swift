//
//  UserStatusMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

final class UserStatusMappingsContainer: RKObjectMapping {
    
    static func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: UserStatus.self)
        mapping?.forceCollectionMapping = true
        mapping?.addAttributeMappingFromKeyOfRepresentation(toAttribute: "identifier")
        mapping?.addAttributeMappings(from: ["(identifier)" : "backendStatus"])
        
        return mapping!
    }
}
