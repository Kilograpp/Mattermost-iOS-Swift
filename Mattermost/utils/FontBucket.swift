//
//  FontUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class FontBucket {
    @nonobjc static let defaultFont = FontBucket.regular15();
    
    @nonobjc static let postDateFont = FontBucket.regular13();
    @nonobjc static let postAuthorNameFont = FontBucket.semibold16();
}

extension FontBucket {
     private static func regular15() -> UIFont {
        return UIFont.init(name: FontNames.regular, size: 15)!
    }
    
    private static func regular13() -> UIFont {
        return UIFont.init(name: FontNames.regular, size: 13)!
    }
    
    private static func semibold16() -> UIFont {
        return UIFont.init(name: FontNames.semibold, size: 16)!
    }
}

struct FontNames {
    static let regular               = "SFUIText-Regular"
    static let semibold              = "SFUIText-Semibold"
    static let medium                = "SFUIText-Medium"
    static let bold                  = "SFUIText-Bold"
    static let italic                = "SFUIText-LightItalic"
    static let regularDisplay        = "SFUIDisplay-Regular"
    static let semiboldDisplay       = "SFUIDisplay-Semibold"
    static let boldDisplay           = "SFUIDisplay-Bold"
    static let mediumDisplay         = "SFUIDisplay-Medium"
}