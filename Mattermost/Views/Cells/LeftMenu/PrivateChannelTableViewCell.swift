//
//  PrivateChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

//FIXME: CodeReview: Final class
//FIXME: CodeReview: Следование протоколу должно быть отдельным extension
class PrivateChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {
    //FIXME: CodeReview: В приват
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var highlightView: UIView!
    
    //FIXME: CodeReview: В приват
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее. Тоже самое со сторой
    var channel : Channel?
    var user : User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configureStatusView()
        self.configurehighlightView()
    }
    
    
    //MARK: - Configuration
    //FIXME: CodeReview: В отдельный extension все методы конфигурации
    //FIXME: CodeReview: Убрать лишние войды везде
    func configureContentView() -> Void {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.hidden = true
    }
    
    func configureTitleLabel() -> Void {
        self.titleLabel.font = FontBucket.normalTitleFont
        //FIXME: CodeReview: Цвет конкретный
        self.titleLabel.textColor = ColorBucket.lightGrayColor
    }
    
    func configureStatusView() -> Void {
        self.statusView.layer.cornerRadius = 4
    }
    
    func configurehighlightView() -> Void {
        self.highlightView.layer.cornerRadius = 3;
    }
    
    func configureUserFormPrivateChannel() {
        self.user = self.channel?.interlocuterFromPrivateChannel()
    }
    
    func configureStatusViewWithUser() {
    }
    
    
    //MARK: - Private
    //FIXME: CodeReview: Цвет конкретный
    func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.whiteColor : ColorBucket.sideMenuBackgroundColor
    }
    
    
    //MARK: - Override
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.highlightView.backgroundColor = highlighted ? ColorBucket.whiteColor.colorWithAlphaComponent(0.5) : self.highlightViewBackgroundColor()
    }

}

extension PrivateChannelTableViewCell {
    func configureWithChannel(channel: Channel, selected: Bool) {
        self.channel = channel
        self.configureUserFormPrivateChannel()
        self.titleLabel.text = channel.displayName!
        //FIXME: CodeReview: Цвет конкретный
        self.highlightView.backgroundColor = selected ? ColorBucket.whiteColor : ColorBucket.sideMenuBackgroundColor
        //FIXME: CodeReview: Цвет конкретный
        self.titleLabel.textColor = selected ? ColorBucket.blackColor : ColorBucket.lightGrayColor
    }
}
