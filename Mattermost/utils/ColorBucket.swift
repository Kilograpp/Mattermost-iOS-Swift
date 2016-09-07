//
//  ColorBucket.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import HEXColor

private protocol PostColors: class {
    static var commonMessageColor: UIColor {get}
    static var systemMessageColor: UIColor {get}
    static var hashtagColor: UIColor {get}
    static var mentionColor: UIColor {get}
    static var mentionBackgroundColor: UIColor {get}
    static var linkColor: UIColor {get}
}

private protocol CommonColors: class {
    static var blackColor: UIColor {get}
    static var whiteColor: UIColor {get}
    static var blueColor: UIColor {get}
    static var grayColor: UIColor {get}
    static var lightGrayColor: UIColor {get}
    static var darkGrayColor: UIColor {get}
    static var onlineStatusColor: UIColor {get}
    static var awayStatusColor: UIColor {get}
}

private protocol SideMenuColors {
    static var sideMenuBackgroundColor: UIColor {get}
    static var sideMenuHeaderBackgroundColor: UIColor {get}
    static var sideMenuCommonTextColor: UIColor {get}
    static var sideMenuSelectedTextColor: UIColor {get}
    static var sideMenuCellHighlightedColor: UIColor {get}
    static var sideMenuCellSelectedColor: UIColor {get}
    static var rightMenuSeparatorColor: UIColor {get}
}

private protocol ServerUrlColors {
    static var serverUrlSubtitleColor: UIColor {get}
}

private protocol GradientColors {
    static var topBlueColorForGradient: UIColor {get}
    static var bottomBlueColorForGradient: UIColor {get}
    static var topRedColorForGradient: UIColor {get}
    static var bottomRedColorForGradient: UIColor {get}
    static var topGreenColorForGradient: UIColor {get}
    static var bottomGreenColorForGradient: UIColor {get}
    static var topOrangeColorForGradient: UIColor {get}
    static var bottomOrangeColorForGradient: UIColor {get}
    static var topPurpleColorForGradient: UIColor {get}
    static var bottomPurpleColorForGradient: UIColor {get}
}

final class ColorBucket {
}

extension ColorBucket : PostColors {
    static let commonMessageColor = ColorBucket.black()
    static let systemMessageColor = ColorBucket.gray()
    static let hashtagColor = ColorBucket.blue()
    static let mentionColor = ColorBucket.blue()
    static let mentionBackgroundColor = UIColor.yellowColor()
    static let linkColor = ColorBucket.blue()
}

extension ColorBucket : CommonColors {
    static let blackColor = ColorBucket.black()
    static let whiteColor = ColorBucket.white()
    static let blueColor = ColorBucket.blue()
    static let grayColor = ColorBucket.gray()
    static let lightGrayColor = ColorBucket.lightGray()
    static let darkGrayColor = ColorBucket.darkGray()
    static let onlineStatusColor = ColorBucket.onlineStatus()
    static let awayStatusColor = ColorBucket.awayStatus()
}

extension ColorBucket : SideMenuColors {
    static let sideMenuBackgroundColor = ColorBucket.deepBlue()
    static let sideMenuHeaderBackgroundColor = ColorBucket.deepLightBlue()
    static let sideMenuCommonTextColor = ColorBucket.sideMenuTextColor()
    static let sideMenuSelectedTextColor = ColorBucket.blackColor
    static let sideMenuCellHighlightedColor = ColorBucket.whiteColor.colorWithAlphaComponent(0.5)
    static let sideMenuCellSelectedColor = ColorBucket.whiteColor
    static let rightMenuSeparatorColor = ColorBucket.sideMenuSeparatorColor()
    static let rightMenuTextColor = ColorBucket.lightBlue()
}

extension ColorBucket : ServerUrlColors {
    static let serverUrlSubtitleColor = ColorBucket.darkDarkGray()
}

extension ColorBucket : GradientColors {
    static let topBlueColorForGradient = UIColor(rgba: "#1D66DE")
    static let bottomBlueColorForGradient = UIColor(rgba: "#248BE2")
    static let topRedColorForGradient = UIColor(rgba: "#9F041B")
    static let bottomRedColorForGradient = UIColor(rgba: "#F5515F")
    static let topGreenColorForGradient = UIColor(rgba: "#429321")
    static let bottomGreenColorForGradient = UIColor(rgba: "#B4EC51")
    static let topOrangeColorForGradient = UIColor(rgba: "#F76B1C")
    static let bottomOrangeColorForGradient = UIColor(rgba: "#FAD961")
    static let topPurpleColorForGradient = UIColor(rgba: "#3023AE")
    static let bottomPurpleColorForGradient = UIColor(rgba: "#C86DD7")
}

extension ColorBucket {
    private class func black() -> UIColor {
        return UIColor(rgba: "#3B3B3B")
    }
    
    private class func white() -> UIColor {
        return UIColor(rgba: "#FFFFFF")
    }
    
    private class func blue() -> UIColor {
        return UIColor(rgba: "#0076FF")
    }
    
    private class func gray() -> UIColor {
        return UIColor(rgba: "#979797")
    }
    
    private class func lightGray() -> UIColor {
        return UIColor(rgba: "#AAAAAA")
    }
    
    private class func darkGray() -> UIColor {
        return UIColor(rgba: "#D8D8D8")
    }
    
    private class func deepBlue() -> UIColor {
        return UIColor(rgba: "#2071A8")
    }
    
    private class func deepLightBlue() -> UIColor {
        return UIColor(rgba: "#2F81B7")
    }
    
    private class func darkDarkGray() -> UIColor {
        return UIColor(rgba: "#334659")
    }
    
    private class func sideMenuSeparatorColor() -> UIColor {
        return UIColor(rgba: "#8798A4")
    }
    
    private class func lightBlue() -> UIColor {
        return UIColor(rgba: "#C3CDD4")
    }
    
    private class func sideMenuTextColor() -> UIColor {
        return UIColor (rgba: "#C3CDD4")
    }
    
    private class func sideMenuHighlightColor() -> UIColor {
        return UIColor(rgba: "#367fb0")
    }
    
    private class func awayStatus() -> UIColor {
        return UIColor(rgba: "#FFCF63")
    }
    
    private class func onlineStatus() -> UIColor {
        return UIColor(rgba: "#81C784")
    }
    
}