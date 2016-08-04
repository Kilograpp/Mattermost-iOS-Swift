//
//  UIImage+Additions.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//
import Foundation

extension UIImage {
    class func roundedImageOfSize(sourceImage: UIImage, size: CGSize) -> UIImage {
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height) as CGRect
        UIGraphicsBeginImageContextWithOptions(size, true, 0);
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        UIColor.whiteColor().setFill()
        CGContextFillRect(context, frame);
        UIBezierPath(roundedRect: frame, cornerRadius: ceil(size.width / 2)).addClip()
        sourceImage.drawInRect(frame)
        
        let result = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
        UIGraphicsEndImageContext();
        
        return result;
    }
    
    @nonobjc static let sharedAvatarPlaceholder = UIImage.avatarPlaceholder()
    
    static func avatarPlaceholder() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40) as CGRect
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        let ref = UIBezierPath(roundedRect: rect, cornerRadius: 20).CGPath
        CGContextAddPath(context, ref);
        CGContextSetFillColorWithColor(context, UIColor.init(white: 0.95, alpha: 1).CGColor);
        CGContextFillPath(context);
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
        UIGraphicsEndImageContext();
        
        return image
    }
    
    func imageByScalingAndCroppingForSize(size: CGSize, radius: CGFloat) -> UIImage {

        let scaleFactor  = size.height / self.size.height
        let scaledWidth  = self.size.width * scaleFactor
        let scaledHeight = self.size.width * scaleFactor
        
        UIGraphicsBeginImageContextWithOptions(size, true, 2)
        
        let thumbnailRect = CGRectMake(0, 0, scaledWidth, scaledHeight)
        
        let context = UIGraphicsGetCurrentContext()
        ColorBucket.lightGrayColor.setFill()
        CGContextFillRect(context, CGRect(origin: CGPointZero, size: size))
        UIBezierPath(roundedRect: CGRect(origin: CGPointZero, size: size), cornerRadius: radius).addClip()
        
        self.drawInRect(thumbnailRect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage
    }
}
