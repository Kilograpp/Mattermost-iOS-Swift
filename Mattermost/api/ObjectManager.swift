//
// Created by Maxim Gubin on 28/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//

import Foundation


class ObjectManager: RKObjectManager {
}

private protocol GetRequests {
    func getObjectsAtPath(path: String,
                          parameters: [NSObject : AnyObject]?,
                          success: ((mappingResult: RKMappingResult) -> Void)?,
                          failure: ((error: Error) -> Void)?)
    
    func getObjectsAtPath(path: String, parameters: [NSObject : AnyObject]?,
                          success: ((operation: RKObjectRequestOperation, mappingResult: RKMappingResult) -> Void)?,
                          failure: ((error: Error) -> Void)?)
    
    
    func getObject(object: AnyObject,
                   path: String!,
                   success: ((mappingResult: RKMappingResult) -> Void)?,
                   failure: ((error: Error) -> Void)?)
}

private protocol PostRequests {
    func postObject(object: AnyObject?,
                    path: String!,
                    parameters: [NSObject : AnyObject]?,
                    success: ((mappingResult: RKMappingResult) -> Void)?,
                    failure: ((error: Error) -> Void)?)

    func postImage(with image: UIImage!,
                   name: String!,
                   path: String!,
                   parameters: [NSObject : AnyObject]?,
                   success: ((mappingResult: RKMappingResult) -> Void)?,
                   failure: ((error: Error) -> Void)?)
}

private protocol Helpers {
    func handleOperation(operation: RKObjectRequestOperation, withError error: NSError) -> Error
}

// MARK: Get Requests
extension ObjectManager: GetRequests {
    
    func getObject(object: AnyObject? = nil,
                   path: String,
                   parameters: [NSObject : AnyObject]? = nil,
                   success: ((mappingResult: RKMappingResult) -> Void)?,
                   failure: ((error: Error?) -> Void)?) {
        super.getObject(object, path: path, parameters: parameters, success: { (operation, mappingResult) in
            success?(mappingResult: mappingResult)
            }) { (operation, error) in
                failure?(error: self.handleOperation(operation, withError: error))
        }
        
      
    }
    
    func getObjectsAtPath(path: String,
                          parameters: [NSObject : AnyObject]?,
                          success: ((mappingResult: RKMappingResult) -> Void)?,
                          failure: ((error: Error) -> Void)?) {
        super.getObjectsAtPath(path, parameters: parameters, success: { (_, mappingResult) in
            success?(mappingResult: mappingResult);
        }, failure: { (operation, error) in
            failure?(error: self.handleOperation(operation, withError: error))
        })
    }
    
    func getObjectsAtPath(path: String, parameters: [NSObject : AnyObject]? = nil,
                          success: ((operation: RKObjectRequestOperation, mappingResult: RKMappingResult) -> Void)?,
                          failure: ((error: Error) -> Void)?){
        super.getObjectsAtPath(path, parameters: parameters, success: { (operation, mappingResult) in
            success?(operation: operation, mappingResult: mappingResult)
        }) { (operation, error) in
            failure?(error: self.handleOperation(operation, withError: error))
        }
    }
    
    func getObject(object: AnyObject, path: String!, success: ((mappingResult: RKMappingResult) -> Void)?, failure: ((error: Error) -> Void)?) {
        super.getObject(object, path: path, parameters: nil, success: { (_, mappingResult) in
            success?(mappingResult: mappingResult)
        }) { (operation, error) in
            failure?(error: self.handleOperation(operation, withError: error))
        }
    }
}

// MARK: Post Requests
extension ObjectManager: PostRequests {
    func postObject(object: AnyObject? = nil,
                    path: String!,
                    parameters: [NSObject : AnyObject]? = nil,
                    success: ((mappingResult: RKMappingResult) -> Void)?,
                    failure: ((error: Error) -> Void)?) {
        super.postObject(object, path: path, parameters: parameters, success: { (_, mappingResult) in
            success?(mappingResult: mappingResult)
        }) { (operation, error) in
            failure?(error: self.handleOperation(operation, withError: error))
        }
    }
    
    func postImage(with image: UIImage!,
                   name: String!,
                   path: String!,
                   parameters: [NSObject : AnyObject]?,
                   success: ((mappingResult: RKMappingResult) -> Void)?,
                   failure: ((error: Error) -> Void)?) {
        
        let constructingBodyWithBlock = {(formData: AFMultipartFormData!) -> Void in
            formData.appendPartWithFileData(UIImagePNGRepresentation(image), name: name, fileName: "file.png", mimeType: "image/png")
        }
        
        let request: NSMutableURLRequest = self.multipartFormRequestWithObject(nil, method: .POST, path: path,
                                                                               parameters: parameters,
                                                                               constructingBodyWithBlock: constructingBodyWithBlock)
        
        let successHandlerBlock = {(operation: RKObjectRequestOperation!, mappingResult: RKMappingResult!) -> Void in
            success?(mappingResult: mappingResult)
        }
        let failureHandlerBlock = {(operation: RKObjectRequestOperation!, error: NSError!) -> Void in
            failure?(error: self.handleOperation(operation, withError: error))
        }
        
        let operation: RKObjectRequestOperation = self.objectRequestOperationWithRequest(request,
                                                                                         success: successHandlerBlock,
                                                                                         failure: failureHandlerBlock)
        self.enqueueObjectRequestOperation(operation)

    }
}


// MARK: Helpers
extension ObjectManager: Helpers {
    private func handleOperation(operation: RKObjectRequestOperation, withError error: NSError) -> Error {
        return Error.errorWithGenericError(error)
    }
}
