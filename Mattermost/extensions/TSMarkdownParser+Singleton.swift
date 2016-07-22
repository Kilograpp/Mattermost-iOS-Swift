//
//  TSMarkdownParser+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import TSMarkdownParser

extension TSMarkdownParser {
    @nonobjc static let sharedInstance = TSMarkdownParser.customParser();
    
    private static func customParser() -> TSMarkdownParser {
        let defaultParser = TSMarkdownParser()
        return defaultParser
    }
}