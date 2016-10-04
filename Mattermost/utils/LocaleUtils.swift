//
//  LocaleUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 01/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class LocaleUtils {
    class func currentLocale() -> String {
        return Locale.preferredLanguages.first!
    }
}
