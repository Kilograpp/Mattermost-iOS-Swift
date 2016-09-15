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
        let mapping = RKObjectMapping(forClass: UserStatus.self)
        mapping.forceCollectionMapping = true
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute("identifier")
        mapping.addAttributeMappingsFromDictionary(["(identifier)" : "backendStatus"])
        
        return mapping
    }
}
