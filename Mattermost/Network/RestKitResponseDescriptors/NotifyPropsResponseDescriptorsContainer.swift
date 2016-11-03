//
//  NotifyPropsResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 03.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func updateNotifyPropsResponseDescriptor() -> RKResponseDescriptor
}


class NotifyPropsResponseDescriptorsContainer: BaseResponseDescriptorsContainer {

}


//MARK: ResponseDescriptors
extension NotifyPropsResponseDescriptorsContainer: ResponseDescriptors {
    static func updateNotifyPropsResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: NotifyPropsMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: NotifyPropsPathPatternsContainer.updatePathPattern(),
                                    keyPath: "notify_props",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
