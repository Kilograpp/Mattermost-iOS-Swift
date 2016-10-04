//
//  PublicChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

private protocol PrivateConfiguration : class {
    func configureContentView()
    func configureTitleLabel()
    func configurehighlightView()
    func highlightViewBackgroundColor() -> UIColor
}

final class PublicChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {
    @IBOutlet fileprivate weak var badgeLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var highlightView: UIView!
    
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее.(см как аутлеты)
    var channel : Channel?
    var test : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureContentView()
        configureTitleLabel()
        configurehighlightView()
    }
    
    //MARK: - Configuration
    func configureStatusViewWithNotification(_ notification: Notification) {
        self.test?()
    }

//MARK: - Override
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.highlightView.backgroundColor = highlighted ? ColorBucket.sideMenuCellHighlightedColor : self.highlightViewBackgroundColor()
    }
}

extension PublicChannelTableViewCell : PrivateConfiguration {
    fileprivate func configureContentView() {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.isHidden = true
    }
    
    fileprivate func configureTitleLabel() {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
    }
    
    fileprivate func configurehighlightView() {
        self.highlightView.layer.cornerRadius = 3;
    }

    fileprivate func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
    }
}

extension PublicChannelTableViewCell {
    func configureWithChannel(_ channel: Channel, selected: Bool) {
        self.channel = channel
        self.titleLabel.text = "# \(channel.displayName!)"
        self.highlightView.backgroundColor = selected ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
        self.titleLabel.font = (channel.hasNewMessages()) ? FontBucket.highlighTedTitleFont : FontBucket.normalTitleFont
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
