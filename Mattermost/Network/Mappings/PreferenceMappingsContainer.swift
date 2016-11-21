//
//  PreferenceMappingsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 31.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol RequestMapping: class {
    static func preferenceRequestMapping() -> RKObjectMapping
}

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
}


final class PreferenceMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return Preference.self
    }
}


//MARK: RequestMapping
extension PreferenceMappingsContainer: RequestMapping {
    static func preferenceRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.request()
        mapping?.addAttributeMappings(from: [
            PreferenceAttributes.userId : "user_id",
            PreferenceAttributes.category : "category",
            PreferenceAttributes.name : "name",
            PreferenceAttributes.value : "value"
            ])
        return mapping!
    }
}


//MARK: ResponseMappings
extension PreferenceMappingsContainer: ResponseMappings {
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "user_id"  : PreferenceAttributes.userId.rawValue,
            "category" : PreferenceAttributes.category.rawValue,
            "name"     : PreferenceAttributes.name.rawValue,
            "value"    : PreferenceAttributes.value.rawValue
            ])
        return mapping
    }
}
