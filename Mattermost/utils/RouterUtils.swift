//
//  RouterUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import MFSideMenu


class RouterUtils {
    class func loadInitialScreen() {
        let isSignedIn = UserStatusManager.sharedInstance.isSignedIn()
        if isSignedIn {
            loadConversationScene()
        } else {
            loadLoginScene()
        }
    }
    
    fileprivate class func loadLoginScene() -> Void {
        let sb = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    fileprivate class func loadConversationScene() -> Void {
        let sb = UIStoryboard.init(name: "Main", bundle: nil) 
        let centerVc = sb.instantiateInitialViewController()
        let leftVc = sb.instantiateViewController(withIdentifier: String(describing: "LeftMenuViewController"))
        let rightVc = sb.instantiateViewController(withIdentifier: String(describing: "RightMenuViewController"))
        let sideMenuContainer = RouterUtils.sideMenuContainer(centerVc!, leftMenuViewController: leftVc, rightMenuViewController: rightVc)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = sideMenuContainer
        appDelegate.window?.makeKeyAndVisible()
    }
}


//MARK: Helpers

extension RouterUtils {
    
    fileprivate class func sideMenuContainer(_ centerViewController: AnyObject, leftMenuViewController: AnyObject, rightMenuViewController: AnyObject) -> MFSideMenuContainerViewController {
        let container = MFSideMenuContainerViewController.init()
        container.leftMenuViewController = leftMenuViewController as! UIViewController
        container.rightMenuViewController = rightMenuViewController as! UIViewController
        container.centerViewController = centerViewController
        
        container.leftMenuWidth = UIScreen.screenWidth() - 51
        container.rightMenuWidth = UIScreen.screenWidth() - 51
        container.menuAnimationDefaultDuration = 0.3
        container.modalTransitionStyle = .crossDissolve
        
        return container
    }
}

extension MFSideMenuContainerViewController {
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
}
