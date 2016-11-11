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
    
    func showSuccesWithMessage(message:String, viewController: UIViewController) {
        let alertView = AlertView(type: .success, message: message)
        alertView.presentingViewController = viewController//.navigationController
        alertView.showAlertView(animated: true)
    }
    
    func showErrorWithMessage(message:String, viewController: UIViewController) {
        let alertView = AlertView(type: .error, message: message)
        alertView.presentingViewController = viewController//.navigationController
        alertView.showAlertView(animated: true)
    }
    
    func showWarningWithMessage(message:String, viewController: UIViewController) {
        let alertView = AlertView(type: .warning, message: message)
        alertView.presentingViewController = viewController//.navigationController
        alertView.showAlertView(animated: true)
    }
}
