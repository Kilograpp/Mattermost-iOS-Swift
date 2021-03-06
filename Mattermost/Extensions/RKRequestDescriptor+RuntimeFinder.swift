//
//  RKRequestDescriptor+RuntimeFinder.swift
//  Mattermost
//
//  Created by Maxim Gubin on 01/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

extension RKRequestDescriptor {
    class func findAllDescriptors() -> Array<RKRequestDescriptor>{
        return dumpValues(fromRootClass: BaseRequestDescriptorsContainer.self, withClassPrefix: Constants.Common.RestKitPrefix) as! Array
    }
}
