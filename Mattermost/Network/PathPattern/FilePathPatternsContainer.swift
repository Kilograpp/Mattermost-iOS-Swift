//
//  FilePathPatternsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PathPatterns: class {
    static func uploadPathPattern() -> String
    static func downloadPathPattern() -> String
    static func thumbPathPattern() -> String
    static func updateCommonPathPattern() -> String
    static func getInfoPathPattern() -> String
}

final class FilePathPatternsContainer: PathPatterns {
    static func downloadPathPattern() -> String {
        return "teams/:\(File.teamIdentifierPath())/files/get:\(FileAttributes.rawLink)"
    }
    static func thumbPathPattern() -> String {
        return "teams/:\(File.teamIdentifierPath())/files/get:thumbPostfix\\.jpg"
    }
    static func updateCommonPathPattern() -> String {
        return "teams/:path/files/get_info/:path/:path/:path/:path"
    }
    static func uploadPathPattern() -> String {
        return "teams/:identifier/files/upload"
    }
    static func getInfoPathPattern() -> String {
        return "teams/:path/files/get_info/:path/:path/:path/:path/"
    }
}
