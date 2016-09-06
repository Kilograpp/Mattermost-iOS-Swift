//
//  NSDate+Formatter.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import DateTools

extension NSDate {
    func messageTimeFormat() -> String {
        return self.formattedDateWithFormat("HH:mm")
    }
    func messageDateFormat() -> String {
        return self.formattedDateWithFormat("dd.MM.yyyy")
    }
    func feedSectionDateFormat() -> String {
        return self.formattedDateWithFormat("MMM dd,yyyy", locale: NSLocale(localeIdentifier: "en_US_POSIX"))
    }
    
    func messageDateFormatForChannel() -> String {
        return self.formattedDateWithFormat("MMM d", locale: NSLocale(localeIdentifier: "en_US_POSIX"))
    }
}