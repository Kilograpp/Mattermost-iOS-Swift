//
//  NotificationsUtils.swift
//  Mattermost
//
//  Created by Екатерина on 03.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit


final class NotificationsUtils: NSObject {
    static func shouldRegisterForRemoteNotifications() -> Bool {
        return (Preferences.sharedInstance.deviceUUID != nil)
    }
    
    static func subscribeToRemoteNotificationsIfNeeded(completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        if shouldRegisterForRemoteNotifications() {
            Api.sharedInstance.subscribeToRemoteNotifications(completion: completion)
        } else {
            completion(nil)
        }
    }
    
   static func registerForRemoteNotifications() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    static func saveNotificationsToken(token: Data) {
        var tokenString = (token as NSData).description.trimmingCharacters(in: CharacterSet.init(charactersIn: "<>"))
        tokenString = tokenString.replacingOccurrences(of: " ", with: "")
        print(tokenString)
        Preferences.sharedInstance.deviceUUID = tokenString
    }
}
