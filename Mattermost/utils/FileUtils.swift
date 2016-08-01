//
//  FileUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 31/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Interface {
    static func downloadLinkForFile(file: File) -> NSURL?
    static func thumbLinkForFile(file: File) -> NSURL?
    static func fileIsImage(file: File) -> Bool
    static func thumbPostfixForInternalFile(file: File) -> String?
}

final class FileUtils {
    static func downloadLinkForFile(file: File) -> NSURL?{
        if  StringUtils.isValidLink(file.rawLink) {
            return NSURL(string: file.rawLink!)
        } else {
            let path = SOCStringFromStringWithObject(File.downloadPathPattern(), file)
            let result = Api.sharedInstance.baseURL().URLByAppendingPathComponent(path.stringByRemovingPercentEncoding!)
            
            return result
        }

    }
    
    static func thumbLinkForFile(file: File) -> NSURL? {
        if  StringUtils.isValidLink(file.rawLink) {
            return NSURL(string: file.rawLink!)
        } else {
            let path = SOCStringFromStringWithObject(File.thumbPathPattern(), file)
            return Api.sharedInstance.baseURL().URLByAppendingPathComponent(path.stringByRemovingPercentEncoding!)
        }

    }
    
    static func thumbPostfixForInternalFile(file: File) -> String? {
        return self.linkWithoutExtension(file.rawLink)?.stringByAppendingString("_thumb")
    }

    
    private static func linkWithoutExtension(link: String?) -> String? {
        return NSURL(string: link ?? StringUtils.emptyString())?.URLByDeletingPathExtension?.absoluteString
    }
    
    static func fileIsImage(file: File) -> Bool {
        return self.stringContainsImagePostfixes(file.rawLink)

    }
    
    static func stringContainsImagePostfixes(string: String?) -> Bool {
        let pathExtension = NSURL(string: string ?? StringUtils.emptyString())?.pathExtension
        if  pathExtension?.caseInsensitiveCompare("png")  == .OrderedSame ||
            pathExtension?.caseInsensitiveCompare("jpg")  == .OrderedSame ||
            pathExtension?.caseInsensitiveCompare("jpeg") == .OrderedSame {
            return true
        } else {
            return false
        }

    }
}