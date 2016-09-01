//
//  AppDelegate.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/06/16.
//  Copyright (c) 2016 Kilograpp. All rights reserved.
//


import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
 //FIXME: вызов методов не должен быть через self
        self.launchApplicationStateManager()
        RouterUtils.loadInitialScreen()

        return true
    }


    func applicationWillResignActive(application: UIApplication) {
    }


    func applicationDidEnterBackground(application: UIApplication) {

    }


    func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }


    func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


    func applicationWillTerminate(application: UIApplication) {

    }
    
    func launchApplicationStateManager() {
        ApplicationStateManager.sharedInstance
    }


}
