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
    @IBOutlet private weak var badgeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var highlightView: UIView!
    
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее.(см как аутлеты)
    var channel : Channel?
    var test : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configurehighlightView()
    }

//MARK: - Override
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.highlightView.backgroundColor = highlighted ? ColorBucket.sideMenuCellHighlightedColor : self.highlightViewBackgroundColor()
    }
}

extension PublicChannelTableViewCell : PrivateConfiguration {
    private func configureContentView() {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.hidden = true
    }
    
    private func configureTitleLabel() {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
    }
    
    private func configurehighlightView() {
        self.highlightView.layer.cornerRadius = 3;
    }

    private func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
    }
}

extension PublicChannelTableViewCell {
    func configureWithChannel(channel: Channel, selected: Bool) {
        self.channel = channel
        self.titleLabel.text = "# \(channel.displayName!)"
        self.highlightView.backgroundColor = selected ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
        self.titleLabel.textColor = selected ? ColorBucket.sideMenuSelectedTextColor : ColorBucket.sideMenuCommonTextColor
    }
    
    func subscribeToNotifications() {

    }
    
    func reloadCell() {
        
    }
}