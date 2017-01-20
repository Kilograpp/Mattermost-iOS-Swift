//
//  PrivateChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

final class PrivateChannelTableViewCell: UITableViewCell {
    
    //MARK: Properies
    
    @IBOutlet fileprivate weak var badgeLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var highlightView: UIView!
    
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее.(см как аутлеты)
    var channel : Channel?
    var test : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.highlightView.backgroundColor = highlighted ? ColorBucket.sideMenuCellHighlightedColor : self.highlightViewBackgroundColor()
    }
    
    func configureStatusViewWithNotification(_ notification: Notification) {
        self.test?()
    }
}

private protocol PrivateChannelTableViewCellSetup {
    func initialSetup()
    func setupContentView()
    func setupTitleLabel()
    func setupHighlightView()
    func setupBadgeLabel()
    func highlightViewBackgroundColor() -> UIColor
}

//MARK: PrivateChannelTableViewCellSetup

extension PrivateChannelTableViewCell: PrivateChannelTableViewCellSetup {
    func initialSetup() {
        setupContentView()
        setupTitleLabel()
        setupHighlightView()
        setupBadgeLabel()
    }
    
    func setupContentView() {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
    
    func setupTitleLabel() {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
    }
    
    func setupHighlightView() {
        self.highlightView.layer.cornerRadius = 3;
    }
    
    func setupBadgeLabel() {
        badgeLabel.layer.cornerRadius = 10;
        badgeLabel.layer.masksToBounds = true
    }
    
    func highlightViewBackgroundColor() -> UIColor {
        return (self.channel?.isSelected == true) ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
    }
}


//MARK: LeftMenuTableViewCellProtocol

extension PrivateChannelTableViewCell: LeftMenuTableViewCellProtocol {
    func configureWithChannel(_ channel: Channel, selected: Bool) {
        self.channel = channel
        self.titleLabel.text = channel.displayName!
        self.highlightView.backgroundColor = selected ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
        self.titleLabel.font = (channel.hasNewMessages()) ? FontBucket.highlighTedTitleFont : FontBucket.normalTitleFont
        badgeLabel.isHidden = (channel.mentionsCount==0)
        badgeLabel.text = String(channel.mentionsCount)
        badgeLabel.font = FontBucket.normalTitleFont

        if selected {
            self.titleLabel.textColor =  (channel.hasNewMessages()) ? ColorBucket.blackColor : ColorBucket.sideMenuSelectedTextColor
        } else {
            self.titleLabel.textColor = (channel.hasNewMessages()) ? ColorBucket.whiteColor : ColorBucket.sideMenuCommonTextColor
        }
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(configureStatusViewWithNotification(_:)),
                                               name: (self.channel?.displayName).map { NSNotification.Name(rawValue: $0) } ,
                                               object: nil)
        
        
    }
    
    func reloadCell() {
        
    }
}
