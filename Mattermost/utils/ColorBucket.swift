//
//  ColorBucket.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

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
}

private protocol SideMenuColors {
    static var sideMenuBackgroundColor: UIColor {get}
    static var sideMenuHeaderBackgroundColor: UIColor {get}
    static var sideMenuCommonTextColor: UIColor {get}
    static var sideMenuSelectedTextColor: UIColor {get}
    static var sideMenuCellHighlightedColor: UIColor {get}
    static var sideMenuCellSelectedColor: UIColor {get}
}

private protocol ServerUrlColors {
    static var serverUrlSubtitleColor: UIColor {get}
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
}

extension ColorBucket : SideMenuColors {
    static let sideMenuBackgroundColor = ColorBucket.deepBlue()
    static let sideMenuHeaderBackgroundColor = ColorBucket.deepLightBlue()
    static let sideMenuCommonTextColor = ColorBucket.lightGrayColor
    static let sideMenuSelectedTextColor = ColorBucket.blackColor
    static let sideMenuCellHighlightedColor = ColorBucket.whiteColor.colorWithAlphaComponent(0.5)
    static let sideMenuCellSelectedColor = ColorBucket.lightGrayColor
}

extension ColorBucket : ServerUrlColors {
    static let serverUrlSubtitleColor = ColorBucket.darkDarkGray()
}

extension ColorBucket {
    private class func black() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#3B3B3B", alpha: 1)!
    }
    
    private class func white() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#FFFFFF", alpha: 1)!
    }
    
    private class func blue() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#0076FF", alpha: 1)!
    }
    
    private class func gray() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#979797", alpha: 1)!
    }
    
    private class func lightGray() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#D8D8D8", alpha: 1)!
    }
    
    private class func darkGray() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#D8D8D8", alpha: 1)!
    }
    
    private class func deepBlue() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#2071A8", alpha: 1)!
    }
    
    private class func deepLightBlue() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#2F81B7", alpha: 1)!
    }
    
    private class func darkDarkGray() -> UIColor {
        return UIColor.hx_colorWithHexRGBAString("#334659", alpha: 1)!
    }
}