//
//  FileUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 31/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SOCKit

private protocol Interface {
    static func downloadLinkForFile(_ file: File) -> URL?
    static func thumbLinkForFile(_ file: File) -> URL?
    static func fileIsImage(_ file: File) -> Bool
    static func thumbPostfixForInternalFile(_ file: File) -> String?
}

final class FileUtils {
    static func downloadLinkForFile(_ file: File) -> URL?{
        if  StringUtils.isValidLink(file.rawLink) {
            return URL(string: file.rawLink!)
        } else {
            let path = SOCStringFromStringWithObject(FilePathPatternsContainer.downloadPathPattern(), file)
            let result = Api.sharedInstance.baseURL().appendingPathComponent(path!.removingPercentEncoding!)
            
            return result
        }

    }
    
    static func thumbLinkForFile(_ file: File) -> URL? {
        if  StringUtils.isValidLink(file.rawLink) {
            return URL(string: file.rawLink!)
        } else {
            let path = SOCStringFromStringWithObject(FilePathPatternsContainer.thumbPathPattern(), file)
            return Api.sharedInstance.baseURL().appendingPathComponent(path!.removingPercentEncoding!)
        }

    }
    
    static func thumbPostfixForInternalFile(_ file: File) -> String? {
        return (self.linkWithoutExtension(file.rawLink))! + "_thumb"
    }

    
    fileprivate static func linkWithoutExtension(_ link: String?) -> String? {
        return URL(string: link ?? StringUtils.emptyString())?.deletingPathExtension().absoluteString
    }
    
    static func fileIsImage(_ file: File) -> Bool {
        return self.stringContainsImagePostfixes(file.rawLink)

    }
    
    static func stringContainsImagePostfixes(_ string: String?) -> Bool {
        let pathExtension = URL(string: string ?? StringUtils.emptyString())?.pathExtension
        if  pathExtension?.caseInsensitiveCompare("png")  == .orderedSame ||
            pathExtension?.caseInsensitiveCompare("jpg")  == .orderedSame ||
            pathExtension?.caseInsensitiveCompare("jpeg") == .orderedSame {
            return true
        } else {
            return false
        }

    }
}
