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


//MARK: Setup
extension LoginNavigationController: Setup {
    func setupNavigationBar() {
        let navBar = self.navigationBar
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        navBar.tintColor = ColorBucket.blackColor
        navBar.backgroundColor = UIColor.clear
        navBar.topItem?.title = ""
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
