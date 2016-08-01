//
//  PublicChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

class PublicChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {

    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highlightView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configurehighlightView()
    }
    
    
    //MARK: - Configuration
    
    func configureContentView() -> Void {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.hidden = true
    }
    
    func configureTitleLabel() -> Void {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
//        self.titleLabel.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
    
    func configurehighlightView() -> Void {
        self.highlightView.layer.cornerRadius = 3;
    }
    
//    override func setSelected(selected: Bool, animated: Bool) {
//        self.highlightView.backgroundColor = selected ? ColorBucket.whiteColor : ColorBucket.sideMenuBackgroundColor
//    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
//        self.highlightView.backgroundColor = highlighted ? ColorBucket.whiteColor.colorWithAlphaComponent(0.5) : ColorBucket.sideMenuBackgroundColor
//        self.highlightView.removeFromSuperview()
        super.setHighlighted(highlighted, animated: animated)
                self.highlightView.backgroundColor = highlighted ? ColorBucket.whiteColor.colorWithAlphaComponent(0.5) : ColorBucket.sideMenuBackgroundColor
    }
}

extension PublicChannelTableViewCell {
    func configureWithChannel(channel: Channel, selected: Bool) {
        self.titleLabel.text = "# \(channel.displayName!)"
    }
}

