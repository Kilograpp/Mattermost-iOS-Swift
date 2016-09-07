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
    
    var titleString : String?
    var channel : Channel?
    var loadingView : UIActivityIndicatorView?
    
    init() {
        super.init(frame: CGRectZero)
            setupBackgroundColor()
            setupStatusView()
            setupTitleLabel()
        setupLoadingView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func configureWithChannel(channel: Channel, loadingInProgress:Bool) {
        self.channel = channel
        self.titleString = channel.displayName
        self.titleLabel?.text = channel.displayName
        self.hideStatusIndicateView()
        
        if channel.privateType == Constants.ChannelType.PrivateTypeChannel {
            
        }
        
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let xPos : CGFloat = 8
        let yPos : CGFloat = CGRectGetHeight(self.bounds)/2 - 2
        self.statusIndicatorView!.frame = CGRectMake(xPos, yPos, 8 ,8)
        guard let channel = self.channel else {
            return
        }

        let titleXPos : CGFloat = channel.privateType == Constants.ChannelType.PrivateTypeChannel ? CGRectGetMaxX((self.statusIndicatorView?.frame)!) + 8  : 8
        
        let titleHeight : CGFloat = 20
        var titleWidth = widthOfString(self.titleString, font: FontBucket.highlighTedTitleFont)
        let titleYPos : CGFloat = CGRectGetHeight(self.bounds)/2 - titleHeight / 2
        
        let availableWidthForTitle : CGFloat = channel.privateType == Constants.ChannelType.PrivateTypeChannel ? CGRectGetWidth(self.bounds) - 42 : CGRectGetWidth(self.bounds) - 26
        titleWidth = min(availableWidthForTitle, titleWidth)
        self.titleLabel?.frame = CGRectMake(titleXPos, titleYPos, titleWidth, titleHeight)
        self.alignSubviews()
    }
    
    func widthOfString(string: String?, font: UIFont) -> CGFloat {
        guard let str = string else {
            return 0.00001
        }
        let stringAttributes = [NSFontAttributeName : font]
        let attr = NSAttributedString.init(string: str, attributes: stringAttributes)
        return ceil(attr.size().width)
        
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
    }
    
    
    }

private protocol Private {
    func hideStatusIndicateView()
    func showStatusIndicateView()
    func toggleLoadingViewVisibility(shouldBeShown: Bool)
    
}

extension ChatNavigationBarTitleView : Private {
    func hideStatusIndicateView() {
        self.statusIndicatorView!.hidden = true
    }
    func showStatusIndicateView() {
        self.statusIndicatorView!.hidden = false
    }
    func toggleLoadingViewVisibility(shouldBeShown: Bool) {
        self.loadingView?.hidden = !shouldBeShown
    }
    
}

private protocol SetupNavigationControler {
    func setupBackgroundColor()
    func setupStatusView()
    func setupTitleLabel()
    func setupLoadingView()
}

extension ChatNavigationBarTitleView : SetupNavigationControler {
    func setupBackgroundColor() {
        self.backgroundColor = ColorBucket.whiteColor
    }
    
    func setupStatusView() {
        let xPosition = CGFloat(8)
        let yPosition = CGFloat(CGRectGetHeight(self.bounds)/2 - 2)
        self.statusIndicatorView = UIView(frame: CGRectMake(xPosition, yPosition, 8, 8))
        self.addSubview(self.statusIndicatorView!)
        self.statusIndicatorView!.layer.cornerRadius = 4
    }
    
    func setupTitleLabel() {
        let xPosition = CGFloat(0)
        let yPosition = CGFloat(0)
        let titleWight = CGFloat(20)
        let titleHeight = CGFloat(20)
        self.titleLabel = UILabel(frame: CGRectMake(xPosition, yPosition, titleWight, titleHeight))
        self.addSubview(self.titleLabel!)
        self.titleLabel?.textColor = ColorBucket.blackColor
        self.titleLabel?.font = FontBucket.normalTitleFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func setupLoadingView() {
        self.loadingView = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        self.addSubview(self.loadingView!)
    }

}