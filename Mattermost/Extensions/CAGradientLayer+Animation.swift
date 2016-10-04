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
    
    static func makeGradientForTopColor(topColor:UIColor, bottomColor:UIColor) -> CAGradientLayer {
        let colors = [topColor.CGColor, bottomColor.CGColor]
        let stopTop = CGFloat(0.0)
        let stopBottom = CGFloat(1.0)
        let locations = [stopTop, stopBottom]
        
        let headerLayer = CAGradientLayer()
        headerLayer.colors = colors
        headerLayer.locations = locations
        
        return headerLayer
    }
    
    func addBaseAnimation(fromColors:[CGColor], toColors:[CGColor]) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: basicAnimationColorKey)
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = Double(animationDuration)
        animation.removedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        return animation
    }
    
    func animateLayerInfinitely(headerLayer:CAGradientLayer) {
        let colorsArray = makeArrayColors(headerLayer)
        var timeDelay:Int
        for i in 1..<colorsArray.count {
            timeDelay = i*animationDuration
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay) * Int64(NSEC_PER_SEC))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                headerLayer.colors = colorsArray[i]
                headerLayer.addAnimation(self.addBaseAnimation(colorsArray[i-1], toColors: colorsArray[i]), forKey: animateGradientKey)
                if ((i + 1) == colorsArray.count) {
                    self.animateLayerInfinitely(headerLayer)
                }
            }
        }
    }
    
    func makeArrayColors(headerLayer:CAGradientLayer) -> [[CGColor]] {
        let fromColors = headerLayer.colors as! [CGColor]
        let toColorsGreen = [ColorBucket.topGreenColorForGradient.CGColor, ColorBucket.bottomGreenColorForGradient.CGColor]
        let toColorsOrange = [ColorBucket.topOrangeColorForGradient.CGColor, ColorBucket.bottomOrangeColorForGradient.CGColor]
        let toColorsRed = [ColorBucket.topRedColorForGradient.CGColor, ColorBucket.bottomRedColorForGradient.CGColor]
        let toColorsPurple = [ColorBucket.topPurpleColorForGradient.CGColor, ColorBucket.bottomPurpleColorForGradient.CGColor]
        let toColorsBlue = [ColorBucket.topBlueColorForGradient.CGColor, ColorBucket.bottomBlueColorForGradient.CGColor]
        let colorsArray = [fromColors, toColorsGreen, toColorsOrange, toColorsRed, toColorsPurple, toColorsBlue]
        
        return colorsArray
    }
    
}