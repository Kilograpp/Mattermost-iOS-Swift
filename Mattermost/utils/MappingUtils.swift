//
//  MappingUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class MappingUtils {}

private protocol TeamMethods {
    static func containsSingleTeam(mappingResult: RKMappingResult) -> Bool
    static func fetchSiteName(mappingResult: RKMappingResult) -> String?
    static func fetchAllTeams(mappingResult: RKMappingResult) -> [Team]
}


// MARK: - Team
extension MappingUtils: TeamMethods {
    static func containsSingleTeam(mappingResult: RKMappingResult) -> Bool {
        return mappingResult.dictionary()["teams"]?.count == 1
    }
    
    static func fetchSiteName(mappingResult: RKMappingResult) -> String? {
        return (String)(mappingResult.dictionary()["client_cfg"]![PreferencesAttributes.siteName.rawValue])
    }
    
    static func fetchAllTeams(mappingResult: RKMappingResult) -> [Team] {
        return mappingResult.dictionary()["teams"] as! [Team]
    }
    
    static func fetchAllChannels(mappingResult: RKMappingResult) -> [Channel] {
        return mappingResult.array() as! [Channel]
    }
}