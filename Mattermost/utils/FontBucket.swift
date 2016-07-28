//
//  FontUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PostFonts {
    static var messageFont: UIFont {get}
    static var postDateFont: UIFont {get}
    static var postAuthorNameFont: UIFont {get}
}

private protocol FeedFonts {
    static var feedSendButtonTitleFont: UIFont {get}
    static var inputTextViewFont: UIFont {get}
    static var sectionTitleFont: UIFont {get}
}

class FontBucket {
}

extension FontBucket : PostFonts {
     static let messageFont = FontBucket.regularFontOfSize(15)
     static let postDateFont = FontBucket.regularFontOfSize(13)
     static let postAuthorNameFont = FontBucket.semiboldFontOfSize(16)
}

extension FontBucket : FeedFonts {
    static let feedSendButtonTitleFont = FontBucket.semiboldFontOfSize(16)
    static let inputTextViewFont = FontBucket.regularFontOfSize(15)
    static let sectionTitleFont = FontBucket.semiboldFontOfSize(16)
}

//MARK: Helpers

extension FontBucket {
    private class func regularFontOfSize(size: CGFloat) -> UIFont {
        return UIFont.init(name: FontNames.Regular, size: size)!
    }
    
    private class func semiboldFontOfSize(size: CGFloat) -> UIFont {
        return UIFont.init(name: FontNames.Semibold, size: size)!
    }
}

private struct FontNames {
    static let Regular               = "SFUIText-Regular"
    static let Semibold              = "SFUIText-Semibold"
    static let Medium                = "SFUIText-Medium"
    static let Bold                  = "SFUIText-Bold"
    static let Italic                = "SFUIText-LightItalic"
    static let RegularDisplay        = "SFUIDisplay-Regular"
    static let SemiboldDisplay       = "SFUIDisplay-Semibold"
    static let BoldDisplay           = "SFUIDisplay-Bold"
    static let MediumDisplay         = "SFUIDisplay-Medium"
}