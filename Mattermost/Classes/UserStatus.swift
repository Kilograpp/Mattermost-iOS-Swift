//
//  UserStatus.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Mappings: class {
    static func mapping() -> RKObjectMapping
}

private protocol ResponseDescriptors: class {
    static func statusResponseDescriptor() -> RKResponseDescriptor
}


final class UserStatus : NSObject {
    var backendStatus: String?
    var identifier: String?
    static var responseDescr = RKResponseDescriptor(mapping: UserStatus.mapping(),
                                             method: .POST,
                                             pathPattern: User.usersStatusPathPattern(),
                                             keyPath: nil,
                                             statusCodes: RKStatusCodeIndexSetForClass(.Successful))
}

extension UserStatus : Mappings {
    static func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: UserStatus.self)
        mapping.forceCollectionMapping = true
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute("identifier")
        mapping.addAttributeMappingsFromDictionary(["(identifier)" : "backendStatus"])
        
        return mapping
    }
}

extension UserStatus : ResponseDescriptors {
    static func statusResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: mapping(),
                                     method: .POST,
                                     pathPattern: User.usersStatusPathPattern(),
                                     keyPath: nil,
                                     statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}