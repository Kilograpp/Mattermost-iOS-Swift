//
//  Error.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

struct Error {
    var code: Int = 0;
    var message: String!
    
    init(error: Swift.Error!) {
        code = (error as NSError).code
        if let errorIndex = Constants.ErrorMessages.code.index(of: code) {
            message = Constants.ErrorMessages.message[errorIndex]
        } else {
            message = (error as NSError).localizedDescription
        }
    }
    
    init(errorCode: Int, errorMessage: String) {
        code = errorCode
        message = errorMessage
    }
    
    internal static  func errorWithGenericError(_ error: Swift.Error!) -> Mattermost.Error {
        return Error(error: error)
    }
    
    internal static func errorWith(code: Int, message: String) -> Mattermost.Error {
        return Error(errorCode: code, errorMessage: message)
    }
}
