//
//  Constants.swift
//  Mattermost
//
//  Created by Maxim Gubin on 29/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

struct Constants {
    struct Api {
        static let Route = "api/v3"
    }
    struct Http {
        struct Headers {
            static let ContentType = "Content-Type"
            static let RequestedWith = "X-Requested-With"
            static let AcceptLanguage = "Accept-Language"
        }
    }
    struct Common {
        static let RestKitPrefix = "RK"
    }
}