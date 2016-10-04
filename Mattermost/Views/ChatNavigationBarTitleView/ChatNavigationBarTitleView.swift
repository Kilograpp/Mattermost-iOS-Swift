//
//  ChatNavigationBarTitleView.swift
//  Mattermost
//
//  Created by Mariya on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class ChatNavigationBarTitleView: UIView {
    
    internal var statusIndicatorView : UIView?
    internal var titleLabel : UILabel?
    internal var disclosureView : UIView?
    
    var titleString : NSString?
    var channel : Channel?
    //var loadingView : UIActivityIndicatorView
    
    internal func configureWithChannel(_ channel: Channel, loadingInProgress:Bool) {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    //Setup
    
    func setupBackgroundColor() {
        self.backgroundColor = ColorBucket.whiteColor
    }
    
    func setupStatusView() {
        let xPosition = CGFloat(8)
        let yPosition = CGFloat(self.bounds.height/2 - 2)
        self.statusIndicatorView = UIView(frame: CGRect(x: xPosition, y: yPosition, width: 8, height: 8))
        self.addSubview(self.statusIndicatorView!)
        self.statusIndicatorView?.layer.cornerRadius = 4
    }
    
    func setupTitleLabel() {
        let xPosition = CGFloat(0)
        let yPosition = CGFloat(0)
        let titleWight = CGFloat(20)
        let titleHeight = CGFloat(20)
        self.titleLabel = UILabel(frame: CGRect(x: xPosition, y: yPosition, width: titleWight, height: titleHeight))
        self.addSubview(self.titleLabel!)
        self.titleLabel?.textColor = ColorBucket.blackColor
        self.titleLabel?.font = FontBucket.normalTitleFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    
    
}
