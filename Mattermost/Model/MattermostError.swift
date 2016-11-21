//
//  MattermostError.swift
//  Mattermost
//
//  Created by TaHyKu on 15.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import RestKit

class MattermostError: /*RealmObject*/RKErrorMessage {
    dynamic var identitier: String? = ""
    dynamic var message: String? = ""
    dynamic var detailedError: String? = ""
    dynamic var requestId: String? = ""
    dynamic var statusCode: Int = 0
    
    internal static func errorWithGenericError(_ genericError: Swift.Error!) -> MattermostError {
        let error = MattermostError()
        error.statusCode = (genericError as NSError).code
        error.message = genericError.localizedDescription
        
        return error
    }
}

public enum MattermostErrorAttributes: String {
    case identifier    = "identifier"
    case message       = "message"
    case detailedError = "detailedError"
    case requestId     = "requestId"
    case statusCode    = "statusCode"
}
