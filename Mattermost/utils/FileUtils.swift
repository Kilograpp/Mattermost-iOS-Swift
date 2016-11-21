//
//  FileUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 31/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SOCKit
import RestKit

private protocol Interface {
    static func downloadLinkForFile(_ file: File) -> URL?
    static func thumbLinkForFile(_ file: File) -> URL?
    static func fileIsImage(_ file: File) -> Bool
    static func thumbPostfixForInternalFile(_ file: File) -> String?
    static func download(file: File, completion: @escaping (_ error: Mattermost.Error?) -> Void, progress: @escaping (_ identifier: String, _ value: Float) -> Void)
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
    
    static func download(file: File,
                         completion: @escaping (_ error: Mattermost.Error?) -> Void,
                         progress: @escaping (_ identifier: String, _ value: Float) -> Void) {
        /*
         https://mattermost.kilograpp.com/api/v3/teams/on95mnb5h7r73n373brm6eddrr/files/get/g453kw9oaifdtpawp456apa6ue/ieiutuie6jgk8g5bk6nb9rh47a/58guznqysp8ifpbi7tei61rrgr/SK%20Donbass-Sport.mp3.zip
         */
        
        //let request: NSMutableURLRequest = NSMutableURLRequest(url: file.downloadURL()!)
        let url = NSURL(string: "https://mattermost.kilograpp.com/api/v3/teams/on95mnb5h7r73n373brm6eddrr/files/get/g453kw9oaifdtpawp456apa6ue/ieiutuie6jgk8g5bk6nb9rh47a/58guznqysp8ifpbi7tei61rrgr/SK%20Donbass-Sport.mp3.zip")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url as! URL)
        request.httpMethod = "GET"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = /*file.downloadURL()?*/url?.lastPathComponent
        let filePath = paths[0].appending("/SK%20Donbass-Sport.mp3.zip"/*file.name!*/)
        
        let operation: AFRKHTTPRequestOperation = AFRKHTTPRequestOperation(request: request as URLRequest!)
        let fullPath = paths[0].appending(/*fileName!*/"/SK%20Donbass-Sport.mp3.zip")
        
        operation.outputStream = OutputStream(toFileAtPath: fullPath, append: false)
        
        operation.setDownloadProgressBlock { (written: UInt, totalWritten: Int64, expectedToWrite: Int64) -> Void in
            print("bytesRead = ", written)
            print("totalBytesRead = ", totalWritten)
            print("totalBytesExpectedToRead = ", expectedToWrite)
            print("progress = ", totalWritten/expectedToWrite * 100)
            //progress(totalBytesRead/(float)totalBytesExpectedToRead * 100.f);
        }
        
        operation.setCompletionBlockWithSuccess({ (operation: AFRKHTTPRequestOperation?, responseObject: Any?) in
            let trimmedFilePath = (((filePath as NSString).deletingLastPathComponent) as NSString).deletingLastPathComponent
            let filePathLastComponent = "/" + ((fileName as? NSString)?.lastPathComponent)!
            let finalFilePath = trimmedFilePath + filePathLastComponent
            
            print(finalFilePath)
            completion(nil)
            }, failure: { (operation: AFRKHTTPRequestOperation?, error: Swift.Error?) -> Void in
              print(error)
                
                //completion(error as! Error?)
        })
        operation.start()
    }
}
