//
//  PreferencesResponseDescriptorContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 30.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func saveResponseDescriptor() -> RKResponseDescriptor
}

final class PreferencesResponseDescriptorContainer: RKResponseDescriptor {
    static var responseDescriptor = RKResponseDescriptor(mapping: nil,//BaseMappingsContainer.emptyResponseMapping(),
                                                         method: .POST,
                                                         pathPattern: PreferencesPathPatterns.savePathPattern(),
                                                         keyPath: nil,
                                                         statusCodes: RKStatusCodeIndexSetForClass(.successful))
}

extension PreferencesResponseDescriptorContainer: ResponseDescriptors {
    static func saveResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: BaseMappingsContainer.emptyResponseMapping(),
                                    method: .POST,
                                    pathPattern: PreferencesPathPatterns.savePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
