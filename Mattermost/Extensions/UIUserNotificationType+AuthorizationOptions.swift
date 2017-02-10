//
//  UIUserNotificationType+AuthorizationOptions.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 09.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation
import UserNotifications

extension UIUserNotificationType {
    
    @available(iOS 10.0, *)
    func authorizationOptions() -> UNAuthorizationOptions {
        var options: UNAuthorizationOptions = []
        if contains(.alert) {
            options.formUnion(.alert)
        }
        if contains(.sound) {
            options.formUnion(.sound)
        }
        if contains(.badge) {
            options.formUnion(.badge)
        }
        return options
    }
    
}
