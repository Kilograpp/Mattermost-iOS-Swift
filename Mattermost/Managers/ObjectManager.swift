 //
// Created by Maxim Gubin on 28/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

final class ObjectManager: RKObjectManager {}

private protocol GetRequests: class {
    func getObjectsAtPath(_ path: String,
                          parameters: [AnyHashable: Any]?,
                          success: ((_ mappingResult: RKMappingResult) -> Void)?,
                          failure: ((_ error: Mattermost.Error) -> Void)?)
    
    func getObjectsAtPath(_ path: String, parameters: [AnyHashable: Any]?,
                          success: ((_ operation: RKObjectRequestOperation, _ mappingResult: RKMappingResult) -> Void)?,
                          failure: ((_ error: Mattermost.Error) -> Void)?)
    
    
    func getObject(_ object: AnyObject,
                   path: String!,
                   success: ((_ mappingResult: RKMappingResult) -> Void)?,
                   failure: ((_ error: Mattermost.Error) -> Void)?)
}

private protocol PostRequests: class {
    func postObject(_ object: AnyObject?,
                    path: String!,
                    parameters: [AnyHashable: Any]?,
                    success: ((_ mappingResult: RKMappingResult) -> Void)?,
                    failure: ((_ error: Mattermost.Error) -> Void)?)

    func postImage(with image: UIImage!,
                   name: String!,
                   path: String!,
                   parameters: [String : String]?,
                   success: ((_ mappingResult: RKMappingResult) -> Void)?,
                   failure: ((_ error: Mattermost.Error) -> Void)?,
                   progress: ((_ progressValue: Float) -> Void)?)
}

private protocol Helpers: class {
    func handleOperation(_ operation: RKObjectRequestOperation, withError error: Swift.Error) -> Mattermost.Error
    func cancelUploadingOperationForImageItem(_ item: AssignedPhotoViewItem)
}

// MARK: Get Requests
extension ObjectManager: GetRequests {
    
    func getObject(_ object: AnyObject? = nil,
                   path: String,
                   parameters: [AnyHashable: Any]? = nil,
                   success: ((_ mappingResult: RKMappingResult, _ canSkipMapping: Bool) -> Void)?,
                   failure: ((_ error: Mattermost.Error?) -> Void)?) {
        
        
        let cachedUrlResponse = URLCache.shared.cachedResponse(for: self.request(with: object, method: .GET, path: path, parameters: parameters) as URLRequest)
        let cachedETag = (cachedUrlResponse?.response as? HTTPURLResponse)?.allHeaderFields["Etag"] as? String
        
        super.getObject(object, path: path, parameters: parameters, success: { (operation, mappingResult) in
            let eTag = operation?.httpRequestOperation.response.allHeaderFields["Etag"] as? String
            success?(mappingResult!, eTag == cachedETag)
        }) { (operation, error) in
            failure?(self.handleOperation(operation!, withError: error!))
        }
        
      
    }
    
    func getObjectsAtPath(_ path: String,
                          parameters: [AnyHashable: Any]?,
                          success: ((_ mappingResult: RKMappingResult) -> Void)?,
                          failure: ((_ error: Mattermost.Error) -> Void)?) {
        super.getObjectsAtPath(path, parameters: parameters, success: { (_, mappingResult) in
            success?(mappingResult!);
        }, failure: { (operation, error) in
            failure?(self.handleOperation(operation!, withError: error!))
        })
    }
    
    func getObjectsAtPath(_ path: String, parameters: [AnyHashable: Any]? = nil,
                          success: ((_ operation: RKObjectRequestOperation, _ mappingResult: RKMappingResult) -> Void)?,
                          failure: ((_ error: Mattermost.Error) -> Void)?){
        super.getObjectsAtPath(path, parameters: parameters, success: { (operation, mappingResult) in
            success?(operation!, mappingResult!)
        }) { (operation, error) in
            failure?(self.handleOperation(operation!, withError: error!))
        }
    }
    
    func getObject(_ object: AnyObject, path: String!, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?) {
        super.getObject(object, path: path, parameters: nil, success: { (_, mappingResult) in
            success?(mappingResult!)
        }) { (operation, error) in
            failure?(self.handleOperation(operation!, withError: error!))
        }
    }
}

// MARK: Post Requests
extension ObjectManager: PostRequests {
    func postObject(_ object: AnyObject? = nil,
                    path: String!,
                    parameters: [AnyHashable: Any]? = nil,
                    success: ((_ mappingResult: RKMappingResult) -> Void)?,
                    failure: ((_ error: Mattermost.Error) -> Void)?) {
        super.post(object, path: path, parameters: parameters, success: { (operation, mappingResult) in
            let eror = try! RKNSJSONSerialization.object(from: operation?.httpRequestOperation.request.httpBody)
            print(eror)
            success?(mappingResult!)
        }) { (operation, error) in
            let eror = try! RKNSJSONSerialization.object(from: operation?.httpRequestOperation.request.httpBody)
            print(eror)
            
            failure?(self.handleOperation(operation!, withError: error!))
        }
    }
    
    func deletePost(with post: Post!,
                        path: String!,
                        parameters: Dictionary<String, String>?,
                        success: ((_ mappingResult: RKMappingResult) -> Void)?,
                        failure: ((_ error: Mattermost.Error) -> Void)?) {
        
        let request: NSMutableURLRequest = self.request(with: nil, method: .POST, path: path, parameters: parameters)
        let successHandlerBlock = {(operation: RKObjectRequestOperation?, mappingResult: RKMappingResult?) -> Void in
            success?(mappingResult!)
        }
        let failureHandlerBlock = {(operation: RKObjectRequestOperation?, error: Swift.Error?) -> Void in
            failure?(self.handleOperation(operation!, withError: error!))
        }
        
        let operation: RKObjectRequestOperation =  self.objectRequestOperation(with: request as URLRequest!, success: successHandlerBlock, failure: failureHandlerBlock)
        self.enqueue(operation)
    }
    
    func postImage(with image: UIImage!,
                        name: String!,
                        path: String!,
                        parameters: Dictionary<String, String>?,
                        success: ((_ mappingResult: RKMappingResult) -> Void)?,
                        failure: ((_ error: Mattermost.Error) -> Void)?,
                        progress: ((_ progressValue: Float) -> Void)?) {
        
        let constructingBodyWithBlock = {(formData: AFRKMultipartFormData?) -> Void in
            formData?.appendPart(withFileData: UIImagePNGRepresentation(image), name: name, fileName: "file.png", mimeType: "image/png")
        }
        
        let request: NSMutableURLRequest = self.multipartFormRequest(with: nil,
                                                                               method: .POST,
                                                                               path: path,
                                                                               parameters: parameters,
                                                                               constructingBodyWith: constructingBodyWithBlock)
        
        let successHandlerBlock = {(operation: RKObjectRequestOperation?, mappingResult: RKMappingResult?) -> Void in
            success?(mappingResult!)
        }
        let failureHandlerBlock = {(operation: RKObjectRequestOperation?, error: Swift.Error?) -> Void in
            failure?(self.handleOperation(operation!, withError: error!))
        }
        
        let operation: RKObjectRequestOperation = self.objectRequestOperation(with: request as URLRequest!,
                                                                                         success: successHandlerBlock,
                                                                                         failure: failureHandlerBlock)
        
        let kg_operation = operation as! KGObjectRequestOperation
        kg_operation.image = image
        kg_operation.httpRequestOperation.setUploadProgressBlock { (written: UInt, totalWritten: Int64, expectedToWrite: Int64) -> Void in
            let value = Float(totalWritten) / Float(expectedToWrite)
            progress?(value)
        }
        self.enqueue(operation)
    }
    
    func postFile(with url: URL!,
                   name: String!,
                   path: String!,
                   parameters: Dictionary<String, String>?,
                   success: ((_ mappingResult: RKMappingResult) -> Void)?,
                   failure: ((_ error: Mattermost.Error) -> Void)?,
                   progress: ((_ progressValue: Float) -> Void)?) {

        let constructingBodyWithBlock = {(formData: AFRKMultipartFormData?) -> Void in
            try! formData?.appendPart(withFileURL: url, name: name)
        }
        
        let request: NSMutableURLRequest = self.multipartFormRequest(with: nil,
                                                                     method: .POST,
                                                                     path: path,
                                                                     parameters: parameters,
                                                                     constructingBodyWith: constructingBodyWithBlock)
        
        let successHandlerBlock = {(operation: RKObjectRequestOperation?, mappingResult: RKMappingResult?) -> Void in
            success?(mappingResult!)
        }
        let failureHandlerBlock = {(operation: RKObjectRequestOperation?, error: Swift.Error?) -> Void in
            failure?(self.handleOperation(operation!, withError: error!))
        }
        
        let operation: RKObjectRequestOperation = self.objectRequestOperation(with: request as URLRequest!,
                                                                              success: successHandlerBlock,
                                                                              failure: failureHandlerBlock)
        
        // для progress
//        let kg_operation = operation as! KGObjectRequestOperation
//        kg_operation.image = image
//        kg_operation.httpRequestOperation.setUploadProgressBlock { (written: UInt, totalWritten: Int64, expectedToWrite: Int64) -> Void in
//            let value = Float(totalWritten) / Float(expectedToWrite)
//            progress?(value)
//        }
        self.enqueue(operation)
    }
}


// MARK: Helpers
extension ObjectManager: Helpers {
    fileprivate func handleOperation(_ operation: RKObjectRequestOperation, withError error: Swift.Error) -> Mattermost.Error {
        return Error.errorWithGenericError(error)
    }
    
    func cancelUploadingOperationForImageItem(_ item: AssignedPhotoViewItem) {
        for operation in self.operationQueue.operations {
            if operation.isKind(of: KGObjectRequestOperation.self) {
                let convertedOperation = operation as! KGObjectRequestOperation
                if convertedOperation.identifier == item.identifier {
                    operation.cancel()
                }
            }
        }
    }
}
