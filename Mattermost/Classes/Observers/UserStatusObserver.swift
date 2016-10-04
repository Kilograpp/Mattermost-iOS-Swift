//
//  UserStatusObserver.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Private : class {
    func updateStatusForUser(_ notification: Notification)
    func setupStatuses(_ notification: Notification)
}

final class UserStatusObserver {
    fileprivate var statuses = [String:String?]()
    static let sharedObserver = UserStatusObserver()
    
    fileprivate init() {
        subscribeForStatusChangingNotifications()
        subscribeForStatusesNotifications()
        subscribeForLogoutNotifications()
    }
    
    func statusForUserWithIdentifier(_ identifier:String) -> UserStatus {
        let status = UserStatus()
        if statuses[identifier] == nil {
            status.backendStatus = "offline"
        } else {
            status.backendStatus = statuses[identifier]!
        }
        
        return status
    }
}

extension UserStatusObserver : Private {
    @objc fileprivate func didLogout() {
        // unsubscribe from all observers
    }
    @objc func updateStatusForUser(_ notification: Notification) {
        let statusNotification = notification.object as! StatusChangingSocketNotification
        statuses[statusNotification.userId] = statusNotification.status
        sendUpdateNotification(statusNotification.userId, status:statusNotification.status)
    }
    
    @objc func setupStatuses(_ notification: Notification) {
        let statusesDictionary = notification.object as! [String:String]
        for (key,value) in statusesDictionary {
            statuses.updateValue(value, forKey: key)
            sendUpdateNotification(key, status:value)
        }
    }
}

//MARK: - Notifications
extension UserStatusObserver {
    fileprivate func subscribeForLogoutNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout),
                                                         name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserLogoutNotificationName),
                                                         object: nil)
    }
    
    fileprivate func subscribeForStatusChangingNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatusForUser),
                                                         name: NSNotification.Name(rawValue: StatusChangingSocketNotification.notificationName()),
                                                         object: nil)
    }
    fileprivate func subscribeForStatusesNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupStatuses),
                                                         name: NSNotification.Name(rawValue: Constants.NotificationsNames.StatusesSocketNotification),
                                                         object: nil)
    }
    
    fileprivate func sendUpdateNotification(_ userIdentifier:String, status:String) {
        let notificationName = userIdentifier
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: status)
        
    }
}
