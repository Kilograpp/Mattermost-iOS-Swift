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
    static func previewPathPattern() -> String
    static func getFileInfosPathPattern() -> String
}

final class FilePathPatternsContainer: PathPatterns {
    static func downloadPathPattern() -> String {
        return "files/:\(FileAttributes.identifier)/get"
    }
    static func thumbPathPattern() -> String {
        return "files/:\(FileAttributes.identifier)/get_thumbnail"
    }
    static func previewPathPattern() -> String {
        return "files/:\(FileAttributes.identifier)/get_preview"
    }
    static func uploadPathPattern() -> String {
        return "teams/:identifier/files/upload"
    }
    static func getFileInfosPathPattern() -> String {
        return "teams/:\(FileWrapperAttributes.teamId)/channels/:\(FileWrapperAttributes.channelId)/posts/:\(FileWrapperAttributes.postId)/get_file_infos"
    }
}
