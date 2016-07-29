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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
    }
    
    
    //MARK: - Configuration
    
    func configureContentView() -> Void {
        self.backgroundColor = ColorBucket.blueColor
    }
    
    func configureTitleLabel() -> Void {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
        self.titleLabel.backgroundColor = ColorBucket.blueColor
    }
    
    func configureWithChannel(channel: Channel) -> Void {
        self.titleLabel.text = "# \(channel.displayName!)"
    }
}

