//
//  PublicChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

//FIXME: CodeReview: Final class
//FIXME: CodeReview: Следование протоколу должно быть отдельным extension
class PublicChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {
//FIXME: CodeReview: В приват
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highlightView: UIView!
    
//FIXME: CodeReview: В приват
    //FIXME: CodeReview: Может быть такое, что ячейка без канала работает? Если нет, то implicity unwrapped ее.(см как аутлеты)
    var channel : Channel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configurehighlightView()
    }
    
    
//FIXME: CodeReview: Марки должны быть выровнены по левому краю как это коммент
    //MARK: - Configuration

//FIXME: CodeReview: Приват
//FIXME: CodeReview: Возвращаемое значение
//FIXME: CodeReview: Extension
    func configureContentView() -> Void {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.hidden = true
    }
    
//FIXME: CodeReview: Лишний void
//FIXME: CodeReview: Функция должна быть приватной
//FIXME: CodeReview: Функция должна быть в отдельном extension
    func configureTitleLabel() -> Void {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
    }
    
//FIXME: CodeReview: Сломан camelCase
//FIXME: CodeReview: Лишний Void
    func configurehighlightView() -> Void {
        self.highlightView.layer.cornerRadius = 3;
    }
    
    
    //MARK: - Private
    
//FIXME: CodeReview: Белый цвет подсветки заменить на конкретный
    func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.whiteColor : ColorBucket.sideMenuBackgroundColor
    }
    
    
    //MARK: - Override
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //FIXME: CodeReview: Цвет конкретный. Чтобы при изменении стиля не охуели.
        self.highlightView.backgroundColor = highlighted ? ColorBucket.whiteColor.colorWithAlphaComponent(0.5) : self.highlightViewBackgroundColor()
    }
}

extension PublicChannelTableViewCell {
    func configureWithChannel(channel: Channel, selected: Bool) {
        self.channel = channel
        self.titleLabel.text = "# \(channel.displayName!)"
    //FIXME: CodeReview: Заменить на конкретный цвет
        self.highlightView.backgroundColor = selected ? ColorBucket.whiteColor : ColorBucket.sideMenuBackgroundColor
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.titleLabel.textColor = selected ? ColorBucket.blackColor : ColorBucket.lightGrayColor
    }
}

