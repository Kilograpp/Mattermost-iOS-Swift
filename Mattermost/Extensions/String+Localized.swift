//
//  String+NSLocalizedString.swift
//  Mattermost
//
//  Created by Mariya on 01.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
