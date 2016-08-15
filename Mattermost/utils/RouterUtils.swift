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
        let isSignedIn = Api.sharedInstance.isSignedIn()
        if isSignedIn {
            loadConversationScene()
        } else {
            loadLoginScene()
        }
    }
    
    private class func loadLoginScene() -> Void {
        let sb = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    private class func loadConversationScene() -> Void {
        let sb = UIStoryboard.init(name: "Main", bundle: nil) 
        let centerVc = sb.instantiateInitialViewController()
        let leftVc = sb.instantiateViewControllerWithIdentifier(String(LeftMenuViewController))
        let rightVc = sb.instantiateViewControllerWithIdentifier(String(RightMenuViewController))
        let sideMenuContainer = RouterUtils.sideMenuContainer(centerVc!, leftMenuViewController: leftVc, rightMenuViewController: rightVc)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = sideMenuContainer
        appDelegate.window?.makeKeyAndVisible()
    }
}


//MARK: Helpers

extension RouterUtils {
    
    private class func sideMenuContainer(centerViewController: AnyObject, leftMenuViewController: AnyObject, rightMenuViewController: AnyObject) -> MFSideMenuContainerViewController {
        let container = MFSideMenuContainerViewController.init()
        container.leftMenuViewController = leftMenuViewController as! UIViewController
        container.rightMenuViewController = rightMenuViewController as! UIViewController
        container.centerViewController = centerViewController
        
        container.leftMenuWidth = UIScreen.screenWidth() - 51
        container.menuAnimationDefaultDuration = 0.3
        container.modalTransitionStyle = .CrossDissolve
        
        return container
    }
}

extension MFSideMenuContainerViewController {
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}