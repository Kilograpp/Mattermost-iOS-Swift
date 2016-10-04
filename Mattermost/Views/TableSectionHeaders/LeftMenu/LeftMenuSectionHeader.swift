//
//  LeftMenuSectionHeader.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 11.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PublicConfiguration {
    func configureWithChannelType(_ channelType: String!)
}

private protocol PrivateSetup : class {
    func setup()
    func setupTitleLabel()
    func setupMoreButton()
    func setupContentView()
}

private protocol Actions {
    func moreAction()
}

final class LeftMenuSectionHeader: UITableViewHeaderFooterView {
    fileprivate let titleLabel: UILabel = UILabel()
    fileprivate let moreButton: UIButton = UIButton()
    static let reuseIdentifier = "LeftMenuSectionHeaderReuseIdentifier"
    var addTapHandler : (() -> Void)?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.frame = CGRect(x: 15, y: 9, width: 150, height: 13)
        let xPos = self.bounds.maxX - 35
        self.moreButton.frame = CGRect(x: xPos, y: 7, width: 15, height: 15)
    }
}

extension LeftMenuSectionHeader : PrivateSetup {
    fileprivate func setup() {
        self.setupTitleLabel()
        self.setupMoreButton()
    }
    
    fileprivate func setupTitleLabel() {
        self.addSubview(self.titleLabel)
        self.titleLabel.font = FontBucket.headerTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
    }
    
    fileprivate func setupMoreButton() {
        self.addSubview(self.moreButton)
        self.moreButton.setBackgroundImage(UIImage(named: "side_menu_more_icon"), for: UIControlState())
        self.moreButton.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
    }
    
    fileprivate func setupContentView() {
        self.contentView.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
}

extension LeftMenuSectionHeader : PublicConfiguration {
    func configureWithChannelType(_ channelType: String!) {
        self.titleLabel.text = channelType.uppercased()
    }
}

extension LeftMenuSectionHeader : Actions {
    func moreAction() {
        self.addTapHandler!()
    }
}
