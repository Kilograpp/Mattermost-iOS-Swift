//
//  CAGradientLayer+Animation.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 05.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
let animationDuration = 10
let animateGradientKey = "animateGradient"
let basicAnimationColorKey = "colors"

extension CAGradientLayer {
    
    
    static func blueGradientForNavigationBar() -> CAGradientLayer {
        let topColor = ColorBucket.topBlueColorForGradient
        let bottomColor = ColorBucket.bottomBlueColorForGradient
        return makeGradientForTopColor(topColor, bottomColor: bottomColor)
    }
    
    static func blueGradientForAvatarImageView() -> CAGradientLayer {
        let topColor = ColorBucket.topBlueColorForGradient
        let bottomColor = ColorBucket.bottomBlueColorForGradient
        return makeGradientForTopColor(topColor, bottomColor: bottomColor)
    }
    
    static func makeGradientForTopColor(_ topColor:UIColor, bottomColor:UIColor) -> CAGradientLayer {
        let colors = [topColor.cgColor, bottomColor.cgColor]
        let stopTop = CGFloat(0.0)
        let stopBottom = CGFloat(1.0)
        let locations = [stopTop, stopBottom]
        
        let headerLayer = CAGradientLayer()
        headerLayer.colors = colors
        headerLayer.locations = locations as [NSNumber]?
        
        return headerLayer
    }
    
    func addBaseAnimation(_ fromColors:[CGColor], toColors:[CGColor]) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: basicAnimationColorKey)
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = Double(animationDuration)
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        //s3 refactor
        // animation.delegate = self
        
        return animation
    }
    
    func animateLayerInfinitely(_ headerLayer:CAGradientLayer) {
        let colorsArray = makeArrayColors(headerLayer)
        var timeDelay:Int
        for i in 1..<colorsArray.count {
            timeDelay = i*animationDuration
            let popTime = DispatchTime.now() + Double(Int64(timeDelay) * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                headerLayer.colors = colorsArray[i]
                headerLayer.add(self.addBaseAnimation(colorsArray[i-1], toColors: colorsArray[i]), forKey: animateGradientKey)
                if ((i + 1) == colorsArray.count) {
                    self.animateLayerInfinitely(headerLayer)
                }
            }
        }
    }
    
    func makeArrayColors(_ headerLayer:CAGradientLayer) -> [[CGColor]] {
        let fromColors = headerLayer.colors as! [CGColor]
        let toColorsGreen = [ColorBucket.topGreenColorForGradient.cgColor, ColorBucket.bottomGreenColorForGradient.cgColor]
        let toColorsOrange = [ColorBucket.topOrangeColorForGradient.cgColor, ColorBucket.bottomOrangeColorForGradient.cgColor]
        let toColorsRed = [ColorBucket.topRedColorForGradient.cgColor, ColorBucket.bottomRedColorForGradient.cgColor]
        let toColorsPurple = [ColorBucket.topPurpleColorForGradient.cgColor, ColorBucket.bottomPurpleColorForGradient.cgColor]
        let toColorsBlue = [ColorBucket.topBlueColorForGradient.cgColor, ColorBucket.bottomBlueColorForGradient.cgColor]
        let colorsArray = [fromColors, toColorsGreen, toColorsOrange, toColorsRed, toColorsPurple, toColorsBlue]
        
        return colorsArray
    }
    
    func updateLayer(_ labelLayer: CAGradientLayer) {
        let colorsArray = makeArrayColors(labelLayer)
        let index = Int(arc4random_uniform(6))
        labelLayer.colors = colorsArray[index]
    }
}
