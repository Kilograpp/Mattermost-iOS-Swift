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
    static func getFileInfosPathPattern() -> String
}

final class FilePathPatternsContainer: PathPatterns {
    static func downloadPathPattern() -> String {
        return "teams/:\(File.teamIdentifierPath())/files/get:\(FileAttributes.rawLink)"
    }
    static func thumbPathPattern() -> String {
        return "teams/:\(File.teamIdentifierPath())/files/get:thumbPostfix\\.jpg"
    }
    static func uploadPathPattern() -> String {
        return "teams/:identifier/files/upload"
    }
    static func getFileInfosPathPattern() -> String {
        //return "teams/:path/files/get_info/:path/:path/:path/:path"
        return "teams/:\(FileWrapperAttributes.teamId)/channels/:\(FileWrapperAttributes.channelId)/posts/:\(FileWrapperAttributes.postId)/get_file_infos"
    }
}


//teams/on95mnb5h7r73n373brm6eddrr/channels/g453kw9oaifdtpawp456apa6ue/posts/a1myxqnwm7nzuxpnhnpb9wz1de/get_file_infos
