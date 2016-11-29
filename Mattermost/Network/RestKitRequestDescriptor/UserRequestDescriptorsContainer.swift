//
//  UserRequestDescriptorsContainer.swift
//  Mattermost
//
//  Created by Екатерина on 26.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol RequestDescriptor: class {
  //  static func updateRequestDescriptor() -> RKRequestDescriptor
}


class UserRequestDescriptorsContainer: BaseRequestDescriptorsContainer {

}


//MARK: RequestDescriptor
extension UserRequestDescriptorsContainer: RequestDescriptor {
    /*   static func updateRequestDescriptor() -> RKRequestDescriptor {
        return RKRequestDescriptor(mapping: UserMappingsContainer.updateRequestMapping(),
                                   objectClass: User.self,
                                   rootKeyPath: nil,
                                   method: .POST)
    }*/
}
