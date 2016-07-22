//
//  UIScreen+Size.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension UIScreen {
    static func screenWidth() -> CGFloat {
        return CGRectGetWidth(UIScreen.mainScreen().bounds)
    }
    
    static func screenHeight() -> CGFloat {
        return CGRectGetHeight(UIScreen.mainScreen().bounds)
    }
}