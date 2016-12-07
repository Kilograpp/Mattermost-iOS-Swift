//
//  SearchRequest.swift
//  Mattermost
//
//  Created by TaHyKu on 07.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import RestKit

class SearchRequest: RealmObject {
    dynamic var identifier: String? = ""
    dynamic var text: String? = ""
    
    override class func primaryKey() -> String { return SearchRequestAttributes.identifier.rawValue }
    override class func indexedProperties() -> [String] { return [SearchRequestAttributes.identifier.rawValue] }
    
    static func generateNewId() -> String {
        let realm = RealmUtils.realmForCurrentThread()
        let searchRequests = realm.objects(SearchRequest.self)
        
        return String(searchRequests.count + 1)
    }
}

public enum SearchRequestAttributes: String {
    case identifier = "identifier"
    case text       = "text"
}
