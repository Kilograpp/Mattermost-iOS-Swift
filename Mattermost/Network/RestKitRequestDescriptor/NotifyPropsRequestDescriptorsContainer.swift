//
//  NotifyPropsRequestDescriptorsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 03.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol RequestDescriptor: class {
    static func updateRequestDescriptor() -> RKRequestDescriptor
}

final class NotifyPropsRequestDescriptorsContainer: BaseRequestDescriptorsContainer {

}


//MARK: RequestDescriptor
extension NotifyPropsRequestDescriptorsContainer: RequestDescriptor {
    static func updateRequestDescriptor() -> RKRequestDescriptor {
        return RKRequestDescriptor(mapping: NotifyPropsMappingsContainer.updateRequestMapping(),
                                   objectClass: NotifyProps.self,
                                   rootKeyPath: nil,
                                   method: .POST)
    }
}
