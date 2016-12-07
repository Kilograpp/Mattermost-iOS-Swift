 //
// Created by Maxim Gubin on 28/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

final class ObjectManager: RKObjectManager {}

private protocol GetRequests: class {
    func get(object: AnyObject?, path: String, parameters: [AnyHashable: Any]?, success: ((_ mappingResult: RKMappingResult, _ canSkipMapping: Bool) -> Void)?, failure: ((_ error: Mattermost.Error?) -> Void)?)
    func get(object: AnyObject, path: String!, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?)
    func getObjectsAt(path: String, parameters: [AnyHashable: Any]?, success: ((_ operation: RKObjectRequestOperation, _ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?)
    func getObjectsAt(path: String, parameters: [AnyHashable: Any]?, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?);
}

private protocol PostRequests: class {
    func post(object: AnyObject?, path: String!, parameters: [AnyHashable: Any]?, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?)
    func deletePostAt(path: String!, parameters: Dictionary<String, String>?, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?)
    func savePreferencesAt(path: String!, parameters: [Dictionary<String, String>], success: ((_ result: Bool) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?)
    func searchPostsWith(terms: String!, path: String!, parameters: Dictionary<String, String>?, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Error) -> Void)?)
    func post(image: UIImage!, identifier: String, name: String!, path: String!, parameters: Dictionary<String, String>?, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?, progress: ((_ progressValue: Float) -> Void)?)
    func postFileWith(url: URL!, identifier: String, name: String!, path: String!, parameters: Dictionary<String, String>?, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?, progress: ((_ progressValue: Float) -> Void)?)
}

private protocol Helpers: class {
    func handleOperation(_ operation: RKObjectRequestOperation, withError error: Swift.Error) -> Mattermost.Error
    func cancelUploadingOperationForImageItem(_ item: AssignedAttachmentViewItem)
}

// MARK: Get Requests
extension ObjectManager: GetRequests {
    func get(object: AnyObject? = nil,
                   path: String,
                   parameters: [AnyHashable: Any]? = nil,
                   success: ((_ mappingResult: RKMappingResult, _ canSkipMapping: Bool) -> Void)?,
                   failure: ((_ error: Mattermost.Error?) -> Void)?) {
        let cachedUrlResponse = URLCache.shared.cachedResponse(for: self.request(with: object, method: .GET, path: path, parameters: parameters) as URLRequest)
        let cachedETag = (cachedUrlResponse?.response as? HTTPURLResponse)?.allHeaderFields["Etag"] as? String
        
        super.getObject(object, path: path, parameters: parameters, success: { (operation, mappingResult) in
            let eTag = operation?.httpRequestOperation.response.allHeaderFields["Etag"] as? String
            print(operation?.httpRequestOperation.responseString ?? "")
            
            success?(mappingResult!, eTag == cachedETag)
        }) { (operation, error) in
            failure?(self.handleOperation(operation!, withError: error!))
        }
    }
    
    func get(object: AnyObject, path: String!, success: ((_ mappingResult: RKMappingResult) -> Void)?, failure: ((_ error: Mattermost.Error) -> Void)?) {
        super.getObject(object, path: path, parameters: nil, success: { (_, mappingResult) in
            success?(mappingResult!)
        }) { (operation, error) in
            failure?(self.handleOperation(operation!, withError: error!))
        }
    }
    
    func getObjectsAt(path: String, parameters: [AnyHashable: Any]? = nil,
                          success: ((_ operation: RKObjectRequestOperation, _ mappingResult: RKMappingResult) -> Void)?,
                          failure: ((_ error: Mattermost.Error) -> Void)?) {
        super.getObjectsAtPath(path, parameters: parameters, success: { (operation, mappingResult) in
            success?(operation!, mappingResult!)
        }) { (operation, error) in
            failure?(self.handleOperation(operation!, withError: error!))
        }
    }
    
    func getObjectsAt(path: String,
                          parameters: [AnyHashable: Any]?,
                          success: ((_ mappingResult: RKMappingResult) -> Void)?,
                          failure: ((_ error: Mattermost.Error) -> Void)?) {
        super.getObjectsAtPath(path, parameters: parameters, success: { (_, mappingResult) in
            success?(mappingResult!)
            }, failure: { (operation, error) in
                failure?(self.handleOperation(operation!, withError: error!))
        })
    }
}

//MARK: Post Requests
extension ObjectManager: PostRequests {
    func post(object: AnyObject? = nil,
              path: String!,
              parameters: [AnyHashable: Any]? = nil,
              success: ((_ mappingResult: RKMappingResult) -> Void)?,
              failure: ((_ error: Mattermost.Error) -> Void)?) {
        super.post(object, path: path, parameters: parameters, success: { (operation, mappingResult) in
            print("SUCCESS")
            print(operation?.httpRequestOperation.responseString)
            success?(mappingResult!)
        }) { (operation, error) in
            print("FAIL")
            print(operation?.httpRequestOperation.responseString)
            let responseString = operation?.httpRequestOperation.responseString
            guard responseString != nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.localizedDescription)!)
                failure?(self.handleOperation(operation!, withError: error!))
                return
            }
            
            let dict = responseString?.toDictionary()
            if (Int((dict?["status_code"])! as! NSNumber) == 500) {
                let statusCode = Int((dict?["status_code"])! as! NSNumber)
                let message = dict?["message"]
                failure?(Error(errorCode: statusCode, errorMessage: message as! String))
            } else {
                failure?(self.handleOperation(operation!, withError: error!))
            }
        }
    }
    
    func deletePostAt(path: String!,
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
    
    func savePreferencesAt(path: String!,
                           parameters: [Dictionary<String, String>],
                           success: ((_ result: Bool) -> Void)?,
                           failure: ((_ error: Mattermost.Error) -> Void)?) {
        let request: NSMutableURLRequest = self.request(with: nil, method: .POST, path: path, parameters: nil)
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let successHandlerBlock = {(operation: RKObjectRequestOperation?, mappingResult: RKMappingResult?) -> Void in
            success?(true)
        }
        let failureHandlerBlock = {(operation: RKObjectRequestOperation?, error: Swift.Error?) -> Void in
            guard (operation?.httpRequestOperation.responseString != /*"true"*/Constants.CommonStrings.True) else { success!(true); return }
            failure?(self.handleOperation(operation!, withError: error!))
        }
        
        let operation: RKObjectRequestOperation = self.objectRequestOperation(with: request as URLRequest!, success: successHandlerBlock, failure: failureHandlerBlock)
        self.enqueue(operation)
    }
    
    func searchPostsWith(terms: String!,
                         path: String!,
                         parameters: Dictionary<String, String>?,
                         success: ((_ mappingResult: RKMappingResult) -> Void)?,
                         failure: ((_ error: Error) -> Void)?) {
        let request: NSMutableURLRequest = self.request(with: nil, method: .POST, path: path, parameters: parameters)
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["terms" : terms!, "is_or_search": true], options: .prettyPrinted)
        
        let successHandlerBlock = {(operation: RKObjectRequestOperation?, mappingResult: RKMappingResult?) -> Void in
            success?(mappingResult!)
        }
        let failureHandlerBlock = {(operation: RKObjectRequestOperation?, error: Swift.Error?) -> Void in
            if (operation?.httpRequestOperation.responseString == "{\"order\":null,\"posts\":null}") {
                success?(RKMappingResult())
            }
            else {
                failure?(self.handleOperation(operation!, withError: error!))
            }
        }
        
        let operation: RKObjectRequestOperation = self.objectRequestOperation(with: request as URLRequest!, success: successHandlerBlock, failure: failureHandlerBlock)
        self.enqueue(operation)
    }
    
    func post(image: UIImage!,
              identifier: String,
              name: String!,
              path: String!,
              parameters: Dictionary<String, String>?,
              success: ((_ mappingResult: RKMappingResult) -> Void)?,
              failure: ((_ error: Mattermost.Error) -> Void)?,
              progress: ((_ progressValue: Float) -> Void)?) {
        let imageName = "\(identifier).png"
        let constructingBodyWithBlock = {(formData: AFRKMultipartFormData?) -> Void in
            formData?.appendPart(withFileData: UIImagePNGRepresentation(image), name: name, fileName: imageName, mimeType: "image/png")
        }
        
        let request: NSMutableURLRequest = self.multipartFormRequest(with: nil,
                                                                     method: .POST,
                                                                     path: path,
                                                                     parameters: parameters,
                                                                     constructingBodyWith: constructingBodyWithBlock)
        
        let successHandlerBlock = {(operation: RKObjectRequestOperation?, mappingResult: RKMappingResult?) -> Void in
            print("upOk"); success?(mappingResult!)
        }
        let failureHandlerBlock = {(operation: RKObjectRequestOperation?, error: Swift.Error?) -> Void in
            //MARK: Cap with fixed later
            guard operation?.httpRequestOperation.responseString != Constants.CommonStrings.True else {
                success!(RKMappingResult())
                return
            }
            print(operation?.httpRequestOperation.responseString ?? "")
            
            print("upFail"); failure?(self.handleOperation(operation!, withError: error!))
        }
        
        print("upStart")
        let operation: RKObjectRequestOperation = self.objectRequestOperation(with: request as URLRequest!, success: successHandlerBlock, failure: failureHandlerBlock)
        
        let kg_operation = operation as! KGObjectRequestOperation
        kg_operation.image = image
        kg_operation.identifier = identifier
        kg_operation.httpRequestOperation.setUploadProgressBlock { (written: UInt, totalWritten: Int64, expectedToWrite: Int64) -> Void in
            let value = Float(totalWritten) / Float(expectedToWrite)
            progress?(value)
        }
        self.enqueue(operation)
    }
    
    func postFileWith(url: URL!,
                  identifier: String,
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
        
        let operation: RKObjectRequestOperation = self.objectRequestOperation(with: request as URLRequest!, success: successHandlerBlock, failure: failureHandlerBlock)
        
        let kg_operation = operation as! KGObjectRequestOperation
        kg_operation.identifier = identifier
        kg_operation.httpRequestOperation.setUploadProgressBlock { (written: UInt, totalWritten: Int64, expectedToWrite: Int64) -> Void in
            let value = Float(totalWritten) / Float(expectedToWrite)
            progress?(value)
        }
        self.enqueue(operation)
    }
    
    func update(user: User, success: ((_ mappingResult: RKMappingResult) -> Void)?,
                failure: ((_ error: Mattermost.Error) -> Void)?) {
        _ = UserPathPatternsContainer.userUpdatePathPattern()
    }
}


// MARK: Helpers
extension ObjectManager: Helpers {
    fileprivate func handleOperation(_ operation: RKObjectRequestOperation, withError error: Swift.Error) -> Mattermost.Error {
        return Error.errorWithGenericError(error)
    }
    
    func cancelUploadingOperationForImageItem(_ item: AssignedAttachmentViewItem) {
        for operation in self.operationQueue.operations {
            guard let operation = operation as? KGObjectRequestOperation else { continue }
            guard operation.identifier == item.identifier else { continue }
            operation.cancel()
        }
    }
}
