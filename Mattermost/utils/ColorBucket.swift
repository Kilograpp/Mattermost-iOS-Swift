//
//  ColorBucket.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


private protocol CommonColors {
    static var blackColor: UIColor {get}
    static var whiteColor: UIColor {get}
    static var blueColor: UIColor {get}
    static var grayColor: UIColor {get}
    static var lightGrayColor: UIColor {get}
    static var darkGrayColor: UIColor {get}
}


class ColorBucket {
}

extension ColorBucket : CommonColors {
    static let blackColor = ColorBucket.black()
    static let whiteColor = ColorBucket.white()
    static let blueColor = ColorBucket.blue()
    static let grayColor = ColorBucket.gray()
    static let lightGrayColor = ColorBucket.lightGray()
    static let darkGrayColor = ColorBucket.darkGray()
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
}