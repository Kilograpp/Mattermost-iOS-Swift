//
//  UIViewController+SharedBar.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 02.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

protocol SharedStatusBar {
    func replaceStatusBar()
}
extension UIViewController: SharedStatusBar {
    func replaceStatusBar() {
        guard let navigationController = self.navigationController else { return }

        UIStatusBar.shared().attach(to: navigationController.view)
    }
}
