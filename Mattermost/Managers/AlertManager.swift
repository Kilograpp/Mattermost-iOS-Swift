//
//  AlertManager.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 10.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

//refactor this. temp functions
enum AlertType {
    case warning
    case error
    case success
}

class AlertManager {
    
    static let sharedManager: AlertManager = AlertManager()
    
    func showSuccesWithMessage(message:String) {
        let alertView = AlertView(type: .success, message: message)
        alertView.showAlertView(animated: true)
    }
    
    func showErrorWithMessage(message:String) {
        let alertView = AlertView(type: .error, message: message)
        alertView.showAlertView(animated: true)
    }
    
    func showWarningWithMessage(message:String) {
        let alertView = AlertView(type: .warning, message: message)
        alertView.showAlertView(animated: true)
    }
}
