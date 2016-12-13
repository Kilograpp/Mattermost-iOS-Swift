//
//  ApplicationStateManager.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ApplicationStateManager {
    static let sharedInstance = ApplicationStateManager()
    
    fileprivate init()  {
        self.subscribeForNotifications()
    }
    deinit {
        self.unsubscribeFromNotifications()
    }
}


private protocol NotificationsSubscription: class {
    func subscribeForNotifications()
    func unsubscribeFromNotifications()
}

private protocol ApplicationDelegate: class {
    func applicationDidEnterBackground()
    func applicationDidBecomeActive()
}

//MARK: - Notification Subscription
extension ApplicationStateManager: NotificationsSubscription {
    fileprivate func subscribeForNotifications() {
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(applicationDidEnterBackground),
                                                         name: NSNotification.Name.UIApplicationDidEnterBackground,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(applicationDidBecomeActive),
                                                         name: NSNotification.Name.UIApplicationDidBecomeActive,
                                                         object: nil)
    }
    
    fileprivate func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ApplicationStateManager {
    func handleLaunchingWithOptionsNotification(notification: Notification) {
        let remoteNotificationInfo = notification.userInfo?[UIApplicationLaunchOptionsKey.remoteNotification]
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationsNames.DidReceiveRemoteNotification), object: remoteNotificationInfo)
    }
}

//MARK: - Application Delegate
extension ApplicationStateManager: ApplicationDelegate {
    @objc func applicationDidEnterBackground() {
        SocketManager.sharedInstance.disconnect()
        Preferences.sharedInstance.save()
    }
    
    @objc func applicationDidBecomeActive() {
        SocketManager.sharedInstance.setNeedsConnect()
    }
}
