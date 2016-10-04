//
//  String+Markdown.swift
//  Mattermost
//
//  Created by Maxim Gubin on 06/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import TSMarkdownParser

extension String {
    func markdownAttributedString() -> NSAttributedString? {
        return TSMarkdownParser.sharedInstance.attributedString(fromMarkdown: self)
    }
}
