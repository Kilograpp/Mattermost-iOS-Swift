//
//  UserStatus.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol Public : class {
    func refreshWithBackendStatus(_ backendStatus: String!)
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

}

extension UserStatus : Public {
    func refreshWithBackendStatus(_ backendStatus: String!) {
        self.backendStatus = backendStatus
        
        
    }
}

extension UserStatus : Private {
    func postNewStatusNotification() {
//        print("POSTED \(self.identifier as String!)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "\(self.identifier  as String!)"), object: self.backendStatus  as String!, userInfo: nil)
    }
}
