//
//  RKResponseDescriptor+RuntimeFinder.swift
//  Mattermost
//
//  Created by Maxim Gubin on 01/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

extension RKResponseDescriptor {
    class func findAllDescriptors() -> Array<RKResponseDescriptor>{
        let descriptors = dumpValues(fromRootClass: BaseResponseDescriptorsContainer.self, withClassPrefix: Constants.Common.RestKitPrefix) as! Array<RKResponseDescriptor>
        let userStatusDesc: Array<RKResponseDescriptor> = [UserStatusResponseDescriptorsContainer.responseDescriptor!]
        return descriptors + userStatusDesc
    }
}
