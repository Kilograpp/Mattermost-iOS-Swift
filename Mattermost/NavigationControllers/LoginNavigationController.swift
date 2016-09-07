//
//  LoginNavigationController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class LoginNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
}

private protocol Setup {
    func setupNavigationBar()
}

extension LoginNavigationController: Setup {
    func setupNavigationBar() {
        let navBar = self.navigationBar
        navBar.translucent = true
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.tintColor = ColorBucket.blackColor
        navBar.backgroundColor = UIColor.clearColor()
        navBar.topItem?.title = ""
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}