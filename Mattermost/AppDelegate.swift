//
//  AppDelegate.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/06/16.
//  Copyright (c) 2016 Kilograpp. All rights reserved.
//


import UIKit
import RealmSwift
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        launchApplicationStateManager()
        
        RouterUtils.loadInitialScreen()
        registerForRemoteNotifications()
        Fabric.with([Crashlytics.self])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //After application becomes active need to load channels in order to fetch correct "mentions_count" (calculation for badges) -jufina
        guard UserStatusManager.sharedInstance.isSignedIn() else { return }
        Api.sharedInstance.getChannelMembers { (error) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func launchApplicationStateManager() {
        _ = ApplicationStateManager.sharedInstance
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.DidReceiveRemoteNotification), object: userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationsUtils.saveNotificationsToken(token: deviceToken)
    }
    
    
    func registerForRemoteNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        let types: UIUserNotificationType = [ .badge, .alert, .sound ]
        NotificationsUtils.registerForRemoteNotifications(types: types)
    }
    
    @available(iOS 10, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        ApplicationStateManager.sharedInstance.obtainRemoteNotificationWithUserInfo(userInfo: userInfo)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.DidReceiveRemoteNotification), object: userInfo)
        completionHandler()
    }
}
