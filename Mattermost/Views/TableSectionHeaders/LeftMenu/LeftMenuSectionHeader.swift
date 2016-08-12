//
//  LeftMenuSectionHeader.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 11.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PublicConfiguration {
    func configureWithChannelType(channelType: String!)
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
    private let titleLabel: UILabel = UILabel()
    private let moreButton: UIButton = UIButton()
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
        
        self.titleLabel.frame = CGRectMake(15, 9, 150, 13)
        let xPos = CGRectGetMaxX(self.bounds) - 35
        self.moreButton.frame = CGRectMake(xPos, 7, 15, 15)
    }
}

extension LeftMenuSectionHeader : PrivateSetup {
    private func setup() {
        self.setupTitleLabel()
        self.setupMoreButton()
    }
    
    private func setupTitleLabel() {
        self.addSubview(self.titleLabel)
        self.titleLabel.font = FontBucket.headerTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
    }
    
    private func setupMoreButton() {
        self.addSubview(self.moreButton)
        self.moreButton.setBackgroundImage(UIImage(named: "side_menu_more_icon"), forState: .Normal)
        self.moreButton.addTarget(self, action: #selector(moreAction), forControlEvents: .TouchUpInside)
    }
    
    private func setupContentView() {
        self.contentView.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
}

extension LeftMenuSectionHeader : PublicConfiguration {
    func configureWithChannelType(channelType: String!) {
        self.titleLabel.text = channelType.uppercaseString
    }
}

extension LeftMenuSectionHeader : Actions {
    func moreAction() {
        self.addTapHandler!()
    }
}