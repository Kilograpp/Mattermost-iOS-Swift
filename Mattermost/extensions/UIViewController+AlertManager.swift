//
//  UIViewController+AlertManager.swift
//  Mattermost
//
//  Created by TaHyKu on 16.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol AlertHandle: class {
    func handleErrorWith(message: String)
    func handleWarningWith(message: String)
    func handleSuccesWith(message: String)
}

extension UIViewController {
    func handleErrorWith(message: String) {
        AlertManager.sharedManager.showErrorWithMessage(message: message)
        self.hideLoaderView()
    }
    
    func handleWarningWith(message: String) {
        AlertManager.sharedManager.showWarningWithMessage(message: message)
        self.hideLoaderView()
    }
    
    func handleSuccesWith(message: String) {
        AlertManager.sharedManager.showSuccesWithMessage(message: message)
        self.hideLoaderView()
    }
}

