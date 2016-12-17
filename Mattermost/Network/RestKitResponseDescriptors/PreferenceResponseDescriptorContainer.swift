//
//  PreferenceResponseDescriptorContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 30.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func saveResponseDescriptor() -> RKResponseDescriptor
    static func listPreferencesResponseDescriptor() -> RKResponseDescriptor
}

final class PreferenceResponseDescriptorContainer: BaseResponseDescriptorsContainer {
    
}


//MARK: ResponseDescriptors
extension PreferenceResponseDescriptorContainer: ResponseDescriptors {
    static func saveResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: BaseMappingsContainer.emptyResponseMapping(),
                                    method: .POST,
                                    pathPattern: PreferencesPathPatternsContainer.savePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func listPreferencesResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PreferenceMappingsContainer.mapping() ,
                                    method: .GET,
                                    pathPattern: PreferencesPathPatternsContainer.listPreferencesPathPatterns(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
