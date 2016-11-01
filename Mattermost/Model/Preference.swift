//
//  Preference.swift
//  Mattermost
//
//  Created by TaHyKu on 31.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class Preference: RealmObject {
    dynamic var userId: String?
    dynamic var category: String?
    dynamic var name: String?
    dynamic var value: String?
}

public enum PreferenceAttributes: String {
    case userId = "userId"
    case category = "category"
    case name = "name"
    case value = "value"
    
}
