//
//  UserStatusObserver.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Private : class {
    func updateStatusForUser(notification: NSNotification)
    func setupStatuses(notification: NSNotification)
}

final class UserStatusObserver {
    private var statuses = [String:String?]()
    static let sharedObserver = UserStatusObserver()
    
    private init() {
        subscribeForStatusChangingNotifications()
        subscribeForStatusesNotifications()
        subscribeForLogoutNotifications()
    }
    
    func statusForUserWithIdentifier(identifier:String) -> UserStatus {
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
    @objc private func didLogout() {
        // unsubscribe from all observers
    }
    @objc func updateStatusForUser(notification: NSNotification) {
        let statusNotification = notification.object as! StatusChangingSocketNotification
        statuses[statusNotification.userId] = statusNotification.status
        sendUpdateNotification(statusNotification.userId, status:statusNotification.status)
    }
    
    @objc func setupStatuses(notification: NSNotification) {
        let statusesDictionary = notification.object as! [String:String]
        for (key,value) in statusesDictionary {
            statuses.updateValue(value, forKey: key)
            sendUpdateNotification(value, status:key)
        }
    }
}

//MARK: - Notifications
extension UserStatusObserver {
    private func subscribeForLogoutNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didLogout),
                                                         name: Constants.NotificationsNames.UserLogoutNotificationName,
                                                         object: nil)
    }
    
    private func subscribeForStatusChangingNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateStatusForUser),
                                                         name: StatusChangingSocketNotification.notificationName(),
                                                         object: nil)
    }
    private func subscribeForStatusesNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setupStatuses),
                                                         name: Constants.NotificationsNames.StatusesSocketNotification,
                                                         object: nil)
    }
    
    private func sendUpdateNotification(userIdentifier:String, status:String) {
        let notificationName = userIdentifier
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: status)
        
    }
}