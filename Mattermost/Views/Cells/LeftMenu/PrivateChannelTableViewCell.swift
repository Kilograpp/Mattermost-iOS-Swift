//
//  PrivateChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

//FIXME: CodeReview: Final class
//FIXME: CodeReview: Следование протоколу должно быть отдельным extension
final class PrivateChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {
    //FIXME: CodeReview: В приват
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var highlightView: UIView!
    
    //FIXME: CodeReview: В приват
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее. Тоже самое со сторой
    var channel : Channel?
    var user : User?
    var userBackendStatus: String?
    
    var test : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configureStatusView()
        self.configurehighlightView()
    }
    
    
    //MARK: - Configuration
    //FIXME: CodeReview: В отдельный extension все методы конфигурации
    private func configureContentView() {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.hidden = true
    }
    
    private func configureTitleLabel() {
        self.titleLabel.font = FontBucket.normalTitleFont
        //FIXME: CodeReview: Цвет конкретный
        self.titleLabel.textColor = ColorBucket.lightGrayColor
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
    
    func configureStatusViewWithNotification(notification: NSNotification) {
        let backendStatus = notification.object as! String
//        self.configureStatusViewWithBackendStatus(backendStatus)
        self.test!()
    }
    
    func configureStatusViewWithBackendStatus(backendStatus: String) {
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
    
    //MARK: - Private
    //FIXME: CodeReview: Цвет конкретный
    private func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.whiteColor : ColorBucket.sideMenuBackgroundColor
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

extension PrivateChannelTableViewCell {
    func configureWithChannel(channel: Channel, selected: Bool) {
        self.channel = channel
        self.configureUserFormPrivateChannel()
        self.subscribeToNotifications()
        self.titleLabel.text = channel.displayName!
        //FIXME: CodeReview: Цвет конкретный
        self.highlightView.backgroundColor = selected ? ColorBucket.whiteColor : ColorBucket.sideMenuBackgroundColor
        //FIXME: CodeReview: Цвет конкретный
        self.titleLabel.textColor = selected ? ColorBucket.blackColor : ColorBucket.lightGrayColor
        
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        self.configureStatusViewWithBackendStatus(backendStatus!)
    }
    
    func reloadCell() {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        self.configureStatusViewWithBackendStatus(backendStatus!)
    }
    
    func subscribeToNotifications() {
//        print("SUBSCRIBED_TO \(self.channel?.interlocuterFromPrivateChannel().identifier  as String!)")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.configureStatusViewWithNotification(_:)), name: self.channel?.interlocuterFromPrivateChannel().identifier as String!, object: nil)
    }
}
