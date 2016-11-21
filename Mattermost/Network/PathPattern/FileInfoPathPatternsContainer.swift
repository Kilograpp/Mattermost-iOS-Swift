//
//  FileInfoPathPatternsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 20.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PathPatterns: class {
    static func getInfoPathPattern() -> String
}

class FileInfoPathPatternsContainer: PathPatterns {
    static func getInfoPathPattern() -> String {
        return "teams/:path/files/get_info/:path/:path/:path/:path"
    }
}
