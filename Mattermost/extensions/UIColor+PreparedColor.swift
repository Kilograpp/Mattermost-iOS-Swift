//
//  UIColor+PreparedColor.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import HEXColor

extension UIColor {
    
    class func kg_blackColor() -> UIColor {
        let color = UIColor(rgba:"#3B3B3B")
        return color
    }
    
    class func kg_lightGrayColor() -> UIColor {
        let color = UIColor.lightGrayColor()
        return color
    }
    
    class func kg_lightLightGrayColor() -> UIColor {
        let color = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        return color
    }
}