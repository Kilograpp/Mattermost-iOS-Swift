//
//  UserStatus.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol Mappings: class {
    static func mapping() -> RKObjectMapping
}

private protocol ResponseDescriptors: class {
    static func statusResponseDescriptor() -> RKResponseDescriptor
}

private protocol Public : class {
    func refreshWithBackendStatus(backendStatus: String!)
}

private protocol Private : class {
    func postNewStatusNotification()
}

final class UserStatus : NSObject {
    var backendStatus: String? {
        didSet {
            self.postNewStatusNotification()
        }
    }
    var identifier: String?
    static var responseDescriptor = RKResponseDescriptor(mapping: UserStatus.mapping(),
                                             method: .POST,
                                             pathPattern: UserPathPatternsContainer.usersStatusPathPattern(),
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
                                     pathPattern: UserPathPatternsContainer.usersStatusPathPattern(),
                                     keyPath: nil,
                                     statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}

extension UserStatus : Public {
    func refreshWithBackendStatus(backendStatus: String!) {
        self.backendStatus = backendStatus
        
        
    }
}

extension UserStatus : Private {
    func postNewStatusNotification() {
//        print("POSTED \(self.identifier as String!)")
        NSNotificationCenter.defaultCenter().postNotificationName("\(self.identifier  as String!)", object: self.backendStatus  as String!, userInfo: nil)
    }
}