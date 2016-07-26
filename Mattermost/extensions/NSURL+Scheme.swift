//
//  NSURL+SchemeSwap.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

public enum URLScheme: String {
    case WS    = "ws://"
    case WSS   = "wss://"
    case HTTP  = "http://"
    case HTTPS = "https://"
}

extension NSURL {
    func URLWithScheme(scheme: URLScheme) -> NSURL? {
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: true)
        components?.scheme = scheme.rawValue
        return components?.URL
    }
}