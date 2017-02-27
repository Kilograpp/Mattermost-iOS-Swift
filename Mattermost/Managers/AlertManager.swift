//
//  AlertManager.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 10.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//
import SwiftMessages

//refactor this. temp functions
enum AlertType {
    case warning
    case error
    case success
}

class AlertManager {
    static let sharedManager: AlertManager = AlertManager()
    
    func showFileDownloadedAlert(fileIdentifier: String, canBeOpenned: Bool, tapHandler: @escaping (_ fileIdentifier: String) -> Void) {
        let view = MessageView.viewFromNib(layout: .CardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.success)
        if canBeOpenned {
            view.button?.setTitle("Open".localized, for: .normal)
            view.buttonTapHandler = { _ in
                SwiftMessages.hide()
                tapHandler(fileIdentifier)
            }
        } else {
            view.button?.isHidden = true
        }
        view.configureDropShadow()
        view.configureContent(title: "Success".localized, body: "File was successfully downloaded".localized)
        SwiftMessages.show(view: view)
    }
    
    func showTextCopyMessage() {
        setupDefaultConfig()
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.info)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: "Info".localized, body: "Message copied to clipboard".localized)
        SwiftMessages.show(view: view)
    }
    
    func showLinkCopyMessage() {
        setupDefaultConfig()
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.info)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: "Info".localized, body: "Link copied to clipboard".localized)
        SwiftMessages.show(view: view)
    }
    
    func showSuccesWithMessage(message:String) {
        setupDefaultConfig()
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.success)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: "Success".localized, body: message)
        
        SwiftMessages.show(view: view)

    }
    
    func showErrorWithMessage(message:String) {
        setupDefaultConfig()
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: "Error".localized, body: message)
        
        SwiftMessages.show(view: view)
    }
    
    func showWarningWithMessage(message:String) {
        setupDefaultConfig()
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.warning)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: "Warning".localized, body: message)
        
        SwiftMessages.show(view: view)
    }
    
    func setupDefaultConfig() {
        SwiftMessages.defaultConfig.presentationStyle = .top
        SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.defaultConfig.duration = SwiftMessages.Duration.seconds(seconds: 1.5)
        SwiftMessages.defaultConfig.interactiveHide = true
        SwiftMessages.defaultConfig.preferredStatusBarStyle = UIApplication.shared.statusBarStyle
    }
}
