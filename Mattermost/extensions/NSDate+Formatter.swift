//
//  NSDate+Formatter.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import DateTools

extension Date {
    func messageTimeFormat() -> String {
        return (self as NSDate).formattedDate(withFormat: "HH:mm")
    }
    func messageDateFormat() -> String {
        return (self as NSDate).formattedDate(withFormat: "dd.MM.yyyy")
    }
    func feedSectionDateFormat() -> String {
        return (self as NSDate).formattedDate(withFormat: "MMM dd,yyyy", locale: Locale(identifier: "en_US_POSIX"))
    }
    
    func messageDateFormatForChannel() -> String {
        return (self as NSDate).formattedDate(withFormat: "MMM d", locale: Locale(identifier: "en_US_POSIX"))
    }
    
    func dateFormatForPostKey() -> String {
        return (self as NSDate).formattedDate(withFormat: "MM-dd-yyyy_HH:mm:ss")
    }
}
