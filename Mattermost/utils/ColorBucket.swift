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
    static var channelColor: UIColor {get}
    static var authorColor: UIColor {get}
    static var commonMessageColor: UIColor {get}
    static var systemMessageColor: UIColor {get}
    static var hashtagColor: UIColor {get}
    static var mentionColor: UIColor {get}
    static var mentionBackgroundColor: UIColor {get}
    static var linkColor: UIColor {get}

    static var editBackgroundColor: UIColor {get}
    static var parentBackgroundColor: UIColor {get}
    static var parentSeparatorColor: UIColor {get}
    static var parentAuthorColor: UIColor {get}
    static var parentMessageColor: UIColor {get}
    static var parentShadowColor: UIColor {get}
    static var editSeparatorColor: UIColor {get}
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
    static let channelColor = ColorBucket.middleGray()
    static let authorColor = ColorBucket.middleGray()
    static let commonMessageColor = ColorBucket.black()
    static let systemMessageColor = ColorBucket.gray()
    static let hashtagColor = ColorBucket.blue()
    static let mentionColor = ColorBucket.blue()
    static let mentionBackgroundColor = UIColor.yellow
    static let linkColor = ColorBucket.blue()
    
    static let editBackgroundColor = ColorBucket.cloudyBlue()
    static let parentBackgroundColor = ColorBucket.cloudyWhite()
    static let parentSeparatorColor = ColorBucket.sideMenuSeparatorColor()
    static let parentAuthorColor = ColorBucket.middleGray()
    static let parentMessageColor = UIColor.black
    static let parentShadowColor = UIColor.black
    static let editSeparatorColor = ColorBucket.brightBlue()
    static let searchTextColor = ColorBucket.brightBlue()
    static let searchTextBackgroundColor = ColorBucket.transparentOrange()
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
    static let sideMenuCellHighlightedColor = ColorBucket.whiteColor.withAlphaComponent(0.5)
    static let sideMenuCellSelectedColor = ColorBucket.whiteColor
    static let rightMenuSeparatorColor = ColorBucket.sideMenuSeparatorColor()
    static let rightMenuTextColor = ColorBucket.lightBlue()
}

extension ColorBucket : ServerUrlColors {
    static let serverUrlSubtitleColor = ColorBucket.darkDarkGray()
}

extension ColorBucket : GradientColors {
    //refactor
    static let topBlueColorForGradient = try! UIColor(rgba_throws: "#1D66DE")
    static let bottomBlueColorForGradient = try! UIColor(rgba_throws: "#248BE2")
    static let topRedColorForGradient = try! UIColor(rgba_throws: "#9F041B")
    static let bottomRedColorForGradient = try! UIColor(rgba_throws: "#F5515F")
    static let topGreenColorForGradient = try! UIColor(rgba_throws: "#429321")
    static let bottomGreenColorForGradient = try! UIColor(rgba_throws: "#B4EC51")
    static let topOrangeColorForGradient = try! UIColor(rgba_throws: "#F76B1C")
    static let bottomOrangeColorForGradient = try! UIColor(rgba_throws: "#FAD961")
    static let topPurpleColorForGradient = try! UIColor(rgba_throws: "#3023AE")
    static let bottomPurpleColorForGradient = try! UIColor(rgba_throws: "#C86DD7")
}

extension ColorBucket {
    fileprivate class func black() -> UIColor {
        return try! UIColor(rgba_throws: "#3B3B3B")
    }
    
    fileprivate class func white() -> UIColor {
        return try! UIColor(rgba_throws: "#FFFFFF")
    }
    
    fileprivate class func cloudyWhite() -> UIColor {
        return try! UIColor(rgba_throws: "#F7F7F7")
    }
    
    fileprivate class func blue() -> UIColor {
        return try! UIColor(rgba_throws: "#0076FF")
    }
    
    fileprivate class func gray() -> UIColor {
        return try! UIColor(rgba_throws: "#979797")
    }
    
    fileprivate class func lightGray() -> UIColor {
        return try! UIColor(rgba_throws: "#AAAAAA")
    }
    
    fileprivate class func middleGray() -> UIColor {
        return try! UIColor (rgba_throws: "#424242")
    }
    
    fileprivate class func darkGray() -> UIColor {
        return try! UIColor(rgba_throws: "#D8D8D8")
    }
    
    fileprivate class func deepBlue() -> UIColor {
        return try! UIColor(rgba_throws: "#2071A8")
    }
    
    fileprivate class func deepLightBlue() -> UIColor {
        return try! UIColor(rgba_throws: "#2F81B7")
    }
    
    fileprivate class func cloudyBlue() -> UIColor {
        return try! UIColor(rgba_throws: "#E7F0F6")
    }
    
    fileprivate class func darkDarkGray() -> UIColor {
        return try! UIColor(rgba_throws: "#334659")
    }
    
    fileprivate class func sideMenuSeparatorColor() -> UIColor {
        return try! UIColor(rgba_throws: "#8798A4")
    }
    
    fileprivate class func lightBlue() -> UIColor {
        return try! UIColor(rgba_throws: "#C3CDD4")
    }
    
    fileprivate class func brightBlue() -> UIColor {
        return try! UIColor(rgba_throws: "#007AFF")
    }
    
    fileprivate class func sideMenuTextColor() -> UIColor {
        return try! UIColor (rgba_throws: "#C3CDD4")
    }
    
    fileprivate class func sideMenuHighlightColor() -> UIColor {
        return try! UIColor(rgba_throws: "#367fb0")
    }
    
    fileprivate class func awayStatus() -> UIColor {
        return try! UIColor(rgba_throws: "#FFCF63")
    }
    
    fileprivate class func transparentOrange() -> UIColor {
        return UIColor(hex6: 0xFFCF63, alpha: 0.3)
    }
    
    fileprivate class func onlineStatus() -> UIColor {
        return try! UIColor(rgba_throws: "#81C784")
    }
}
