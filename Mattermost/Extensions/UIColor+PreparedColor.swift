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
        let color = try! UIColor(rgba_throws:"#3B3B3B")
        return color
    }
    
    class func kg_blueColor() -> UIColor {
        let color = try! UIColor(rgba_throws: "#0076FF")
        return color;
    }
    
    class func kg_lightGrayColor() -> UIColor {
        let color = UIColor.lightGray
        return color
    }
    
    class func kg_lightLightGrayColor() -> UIColor {
        let color = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        return color
    }
    
    class func kg_lightBlackColor() -> UIColor {
        let color = UIColor.init(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        return color
    }
    
    class func kg_lightGrayTextColor() -> UIColor {
        let color = UIColor.init(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        return color
    }
    class func kg_editColor() -> UIColor {
        let color = try! UIColor(rgba_throws: "#ffff85")
        return color
    }
}
