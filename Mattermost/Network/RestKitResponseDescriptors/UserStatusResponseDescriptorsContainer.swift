//
//  UserStatusResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func statusResponseDescriptor() -> RKResponseDescriptor
}

final class UserStatusResponseDescriptorsContainer: RKResponseDescriptor {
    
    static var responseDescriptor = RKResponseDescriptor(mapping: UserStatusMappingsContainer.mapping(),
                                                         method: .POST,
                                                         pathPattern: UserPathPatternsContainer.usersStatusPathPattern(),
                                                         keyPath: nil,
                                                         statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    

    
}

extension UserStatusResponseDescriptorsContainer: ResponseDescriptors {
    
    static func statusResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserStatusMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.usersStatusPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}