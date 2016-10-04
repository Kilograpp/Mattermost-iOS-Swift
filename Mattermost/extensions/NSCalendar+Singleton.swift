//
//  NSCalendar+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension Calendar {
    @nonobjc static let sharedGregorianCalendar = Calendar.gregorianCalendar();
    
    fileprivate static func gregorianCalendar() -> Calendar! {
        return Calendar(identifier: Calendar.Identifier.gregorian)
    }
}
