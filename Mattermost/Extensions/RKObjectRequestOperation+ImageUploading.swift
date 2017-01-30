//
//  RKObjectRequestOperation+ImageUploading.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 19.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

class KGObjectRequestOperation: RKObjectRequestOperation {
    var image: UIImage?
    var identifier: String?
    
    override static func canProcessRequest(_ request: URLRequest) -> Bool {
        return true
    }
}
