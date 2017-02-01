//
//  GradientImagesBuilder.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

fileprivate let gradientColors = [[ColorBucket.topGreenColorForGradient.cgColor, ColorBucket.bottomGreenColorForGradient.cgColor],
                                  [ColorBucket.topOrangeColorForGradient.cgColor, ColorBucket.bottomOrangeColorForGradient.cgColor],
                                  [ColorBucket.topRedColorForGradient.cgColor, ColorBucket.bottomRedColorForGradient.cgColor],
                                  [ColorBucket.topPurpleColorForGradient.cgColor, ColorBucket.bottomPurpleColorForGradient.cgColor],
                                  [ColorBucket.topBlueColorForGradient.cgColor, ColorBucket.bottomBlueColorForGradient.cgColor]]

private protocol Public : class {
    static func gradientImageWithType(type: Int, completion:@escaping ((UIImage) -> Void))
}

final class GradientImageBuilder {
    fileprivate static var cache: [Int: UIImage?] = [:]
}

extension GradientImageBuilder : Public {
    static func gradientImageWithType(type: Int, completion:@escaping ((UIImage) -> Void)) {
        defer {
            DispatchQueue.main.async {
                guard let img = cache[type] else {return}
                completion(img!)
            }
        }
        
        guard cache[type] == nil else {
            return
        }
        
        
        DispatchQueue.global(qos: .background).async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientColors[type]
            gradientLayer.bounds = CGRect(x:0, y: 0, width: 40, height: 40)
            UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, true, 0.0)
            let context = UIGraphicsGetCurrentContext()
            gradientLayer.render(in: context!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            cache[type] = image
            UIGraphicsEndImageContext()
        }
    }
}
