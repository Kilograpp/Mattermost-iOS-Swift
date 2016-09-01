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
        let descriptors = dumpValuesFromRootClass(RealmObject.self, withClassPrefix: Constants.Common.RestKitPrefix) as! Array<RKResponseDescriptor>
        let userStatusDesc: Array<RKResponseDescriptor> = [UserStatus.responseDescriptor]
        return descriptors + userStatusDesc
    }
}
