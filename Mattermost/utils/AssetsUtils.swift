//
//  AssetsUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import Photos

class AssetsUtils {
    static func convertedArrayOfAssets(assets: Array<PHAsset>) -> Array<AssignedPhotoViewItem> {
        let assetManager = PHImageManager.defaultManager()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .Exact
        requestOptions.deliveryMode = .HighQualityFormat
        requestOptions.synchronous = true
        var array = Array<AssignedPhotoViewItem>()
        for asset in assets {
            assetManager.requestImageForAsset(asset,
                                              targetSize: PHImageManagerMaximumSize,
                                              contentMode: .AspectFill,
                                              options: requestOptions,
                  resultHandler: { (image, metadata) in
                        array.append(AssignedPhotoViewItem(image: image!))
            })
        }
        
        return array
    }
}