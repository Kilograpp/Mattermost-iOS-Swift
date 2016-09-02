//
//  UIFont+PreparedFont.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

let KGPreparedFontsRegularFontName            = "SFUIText-Regular"
let KGPreparedFontsSemiboldFontName           = "SFUIText-Semibold"
let KGPreparedFontsMediumFontName             = "SFUIText-Medium"
let KGPreparedFontsBoldFontName               = "SFUIText-Bold"
let KGPreparedFontsItalicFontName             = "SFUIText-LightItalic"

let KGPreparedFontsRegularDisplayFontName     = "SFUIDisplay-Regular"
let KGPreparedFontsSemiboldDisplayFontName    = "SFUIDisplay-Semibold"
let KGPreparedFontsBoldDisplayFontName        = "SFUIDisplay-Bold"
let KGPreparedFontsMediumDisplayFontName      = "SFUIDisplay-Medium"

    
//MARK: - Bold

extension UIFont {
   class func kg_bold28Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsBoldDisplayFontName, size:28)
        return font!
    }

    class func kg_bold16Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsBoldDisplayFontName, size:16)
        return font!
    }
}


//MARK: - Regular

extension UIFont {
    
   class func kg_regular12Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsRegularFontName, size:12)
        return font!
    }
    
    class func kg_regular13Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsRegularFontName, size:13)
        return font!
    }
    
    class func kg_regular14Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsRegularFontName, size:14)
        return font!
    }
    
    class func kg_regular15Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsRegularFontName, size:15)
        return font!
    }
    
    class func kg_regular16Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsRegularFontName, size:16)
        return font!
    }
    
    class func kg_regular18Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsRegularFontName, size:18)
        return font!
    }
    
    class func kg_regular36Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsRegularFontName, size:36)
        return font!
    }
}


//MARK: - Semobold

extension UIFont {
    class func kg_semibold30Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsSemiboldFontName, size:30)
        return font!
    }
    
    class func kg_semibold20Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsSemiboldFontName, size:20)
        return font!
    }
    
    class func kg_semibold18Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsSemiboldFontName, size:18)
        return font!
    }
    
    class func kg_semibold16Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsSemiboldFontName, size:16)
        return font!
    }
    
    class func kg_semibold15Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsSemiboldFontName, size:15)
        return font!
    }
    
    class func kg_semibold13Font() -> UIFont {
        let font = UIFont(name:KGPreparedFontsSemiboldFontName, size:13)
        return font!
    }
}

