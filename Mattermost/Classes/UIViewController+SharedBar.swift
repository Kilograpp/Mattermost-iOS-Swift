//
//  UIViewController+SharedBar.swift
//  Mattermost
//
//  Created by Сергей on 09.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol SharedBar {
    func replaceStatusBar()
}

extension UIViewController: SharedBar {
    func replaceStatusBar() {
        guard let navigationController = self.navigationController else { return }
        //UIStatusBar.shared().reset()
        UIStatusBar.shared().attach(to: navigationController.view)
    }
}
