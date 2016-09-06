//
//  PrivateChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

private protocol PrivateConfiguration : class {
    func configureContentView()
    func configureTitleLabel()
    func configureStatusView()
    func configurehighlightView()
    func configureUserFormPrivateChannel()
    func configureStatusViewWithBackendStatus(backendStatus: String)
    func highlightViewBackgroundColor() -> UIColor
}

//FIXME: CodeReview: Следование протоколу должно быть отдельным extension
final class PrivateChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {
    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var badgeLabel: UILabel!
    @IBOutlet private weak var highlightView: UIView!
    
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее. Тоже самое со сторой
    var channel : Channel?
    private var user : User?
    private var userBackendStatus: String?
    
    var test : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configureStatusView()
        self.configurehighlightView()
    }
    
    
//MARK: - Configuration
    func configureStatusViewWithNotification(notification: NSNotification) {
        self.test?()
    }

//MARK: - Override
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.highlightView.backgroundColor = highlighted ? ColorBucket.whiteColor.colorWithAlphaComponent(0.5) : self.highlightViewBackgroundColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeObservers()
        self.test = nil
    }
}

extension PrivateChannelTableViewCell : PrivateConfiguration {
    private func configureContentView() {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.hidden = true
    }
    
    private func configureTitleLabel() {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.sideMenuCommonTextColor
    }
    
    private func configureStatusView() {
        self.statusView.layer.cornerRadius = 4
        self.statusView.layer.borderColor = ColorBucket.lightGrayColor.CGColor
        self.statusView.layer.borderWidth = 1;
    }
    
    private func configurehighlightView() {
        self.highlightView.layer.cornerRadius = 3;
    }
    
    private func configureUserFormPrivateChannel() {
        self.user = self.channel?.interlocuterFromPrivateChannel()
    }
    private func configureStatusViewWithBackendStatus(backendStatus: String) {
        //FIXME в свифте есть swith из строк
        if backendStatus == "offline" {
            self.statusView.backgroundColor = UIColor.clearColor()
            self.statusView.layer.borderWidth = 1;
        } else if backendStatus == "online" {
            self.statusView.backgroundColor = UIColor.greenColor()
            self.statusView.layer.borderWidth = 0;
        } else if backendStatus == "away" {
            self.statusView.backgroundColor = UIColor.yellowColor()
            self.statusView.layer.borderWidth = 0;
        } else {
            self.statusView.layer.borderWidth = 0;
            self.statusView.backgroundColor = UIColor.blackColor()
        }
    }
    
    private func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
    }
}

extension PrivateChannelTableViewCell {
    func configureWithChannel(channel: Channel, selected: Bool) {
        self.channel = channel
        self.configureUserFormPrivateChannel()
        self.subscribeToNotifications()
        self.titleLabel.text = channel.displayName!
        self.highlightView.backgroundColor = selected ? ColorBucket.sideMenuCellHighlightedColor : ColorBucket.sideMenuBackgroundColor
        self.titleLabel.textColor = selected ? ColorBucket.sideMenuSelectedTextColor : ColorBucket.sideMenuCommonTextColor
        
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        self.configureStatusViewWithBackendStatus(backendStatus!)
    }
    
    func reloadCell() {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        self.configureStatusViewWithBackendStatus(backendStatus!)
    }
    
    func subscribeToNotifications() {
//        print("SUBSCRIBED_TO \(self.channel?.interlocuterFromPrivateChannel().identifier  as String!)")
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(configureStatusViewWithNotification(_:)),
                                                         name: self.channel?.interlocuterFromPrivateChannel().identifier as String!,
                                                         object: nil)
    }
}
