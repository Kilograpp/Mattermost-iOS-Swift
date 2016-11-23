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
    static func download(fileId: String, completion: @escaping (_ error: Mattermost.Error?) -> Void, progress: @escaping (_ identifier: String, _ value: Float) -> Void)
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

    static func localLinkFor(file: File) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = "/" + (file.downloadURL()?.lastPathComponent)!
        return paths[0].appending(fileName)
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
    
    static func download(fileId: String,
                         completion: @escaping (_ error: Mattermost.Error?) -> Void,
                         progress: @escaping (_ identifier: String, _ value: Float) -> Void) {
        var file = File.objectById(fileId)
        let request: NSMutableURLRequest = NSMutableURLRequest(url: file!.downloadURL()!)
        request.httpMethod = "GET"
        
        let filePath = self.localLinkFor(file: file!)
        let operation: AFRKHTTPRequestOperation = AFRKHTTPRequestOperation(request: request as URLRequest!)
        operation.outputStream = OutputStream(toFileAtPath: filePath, append: false)
        operation.userInfo = ["identifier" : fileId]
        
        
        operation.setDownloadProgressBlock { (written: UInt, totalWritten: Int64, expectedToWrite: Int64) -> Void in
            let result = Float(totalWritten) / Float(expectedToWrite)
            print("downloading progress = ", result)
            progress(fileId, result)
        }
        
        operation.setCompletionBlockWithSuccess({ (operation: AFRKHTTPRequestOperation?, responseObject: Any?) in
            let realm = RealmUtils.realmForCurrentThread()
            file = realm.object(ofType: File.self, forPrimaryKey: fileId)
            try! realm.write {
                file?.downoloadedSize = (file?.size)!
                file?.localLink = filePath
            }
            print("downloading finished")
            completion(nil)
            }, failure: { (operation: AFRKHTTPRequestOperation?, error: Swift.Error?) -> Void in
                completion(error as! Error?)
        })
        operation.start()
    }
    
    static func cancelDownloading(fileId: String) {
        let file = File.objectById(fileId)
        let filePath = self.localLinkFor(file: file!)
        
    }
}
