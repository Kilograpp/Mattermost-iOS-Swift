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
    func configureStatusViewWithBackendStatus(_ backendStatus: String)
    func highlightViewBackgroundColor() -> UIColor
}

//FIXME: CodeReview: Следование протоколу должно быть отдельным extension
final class PrivateChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {
    @IBOutlet fileprivate weak var statusView: UIView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var badgeLabel: UILabel!
    @IBOutlet fileprivate weak var highlightView: UIView!
    
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее. Тоже самое со сторой
    var channel : Channel?
    fileprivate var user : User?
    fileprivate var userBackendStatus: String?
    
    var test : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configureStatusView()
        self.configurehighlightView()
    }
    
    
//MARK: - Configuration
    func configureStatusViewWithNotification(_ notification: Notification) {
//        self.test?()
        
        configureStatusViewWithBackendStatus(notification.object as! String)
    }

//MARK: - Override
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.highlightView.backgroundColor = highlighted ? ColorBucket.whiteColor.withAlphaComponent(0.5) : self.highlightViewBackgroundColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeObservers()
        self.test = nil
    }
}

extension PrivateChannelTableViewCell : PrivateConfiguration {
    fileprivate func configureContentView() {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.isHidden = true
    }
    
    fileprivate func configureTitleLabel() {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.sideMenuCommonTextColor
    }
    
    fileprivate func configureStatusView() {
        self.statusView.layer.cornerRadius = 4
        self.statusView.layer.borderColor = ColorBucket.lightGrayColor.cgColor
        self.statusView.layer.borderWidth = 1;
    }
    
    fileprivate func configurehighlightView() {
        self.highlightView.layer.cornerRadius = 3;
    }
    
    fileprivate func configureUserFormPrivateChannel() {
        self.user = self.channel?.interlocuterFromPrivateChannel()
    }
    fileprivate func configureStatusViewWithBackendStatus(_ backendStatus: String) {
        print("\(user?.displayName) is \(backendStatus)")
        //FIXME в свифте есть swith из строк
        if backendStatus == "offline" {
            self.statusView.backgroundColor = UIColor.clear
            self.statusView.layer.borderWidth = 1;
        } else if backendStatus == "online" {
            self.statusView.backgroundColor = UIColor.green
            self.statusView.layer.borderWidth = 0;
        } else if backendStatus == "away" {
            self.statusView.backgroundColor = UIColor.yellow
            self.statusView.layer.borderWidth = 0;
        } else {
            self.statusView.layer.borderWidth = 0;
            self.statusView.backgroundColor = UIColor.black
        }
    }
    
    fileprivate func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
    }
}

extension PrivateChannelTableViewCell {
    func configureWithChannel(_ channel: Channel, selected: Bool) {
        self.channel = channel
        self.configureUserFormPrivateChannel()
        self.subscribeToNotifications()
        self.titleLabel.text = channel.displayName!
        
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        self.configureStatusViewWithBackendStatus(backendStatus!)
        
        self.highlightView.backgroundColor = selected ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
        self.titleLabel.font = (channel.hasNewMessages()) ? FontBucket.highlighTedTitleFont : FontBucket.normalTitleFont
        if selected {
            self.titleLabel.textColor =  (channel.hasNewMessages()) ? ColorBucket.blackColor : ColorBucket.sideMenuSelectedTextColor
        } else {
            self.titleLabel.textColor = (channel.hasNewMessages()) ? ColorBucket.whiteColor : ColorBucket.sideMenuCommonTextColor
        }
    }
    
    func reloadCell() {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        self.configureStatusViewWithBackendStatus(backendStatus!)
    }
    
    func subscribeToNotifications() {
//        print("SUBSCRIBED_TO \(self.channel?.interlocuterFromPrivateChannel().identifier  as String!)")
        //s3 refactor identifier / as String! / .map
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(configureStatusViewWithNotification(_:)),
                                                         name: NSNotification.Name((self.channel?.interlocuterFromPrivateChannel().identifier)!),
                                                         object: nil)
    }
}
