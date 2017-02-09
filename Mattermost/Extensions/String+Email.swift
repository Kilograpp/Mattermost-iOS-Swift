//
//  String+Email.swift
//  Mattermost
//
//  Created by TaHyKu on 07.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

fileprivate let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{3,}"

extension String {
    func isValidEmail() -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailTest.evaluate(with: self)
    }
}
