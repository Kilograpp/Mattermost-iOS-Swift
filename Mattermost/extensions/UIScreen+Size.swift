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
        return UIScreen.main.bounds.width
    }
    
    static func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
}
