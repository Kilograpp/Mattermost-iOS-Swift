//
//  LeftMenuSectionFooter.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PrivateSetup : class {
    func setup()
    func setupTitleButton()
    func setupContentView()
}

private protocol Actions {
    func moreAction()
}

final class LeftMenuSectionFooter : UITableViewHeaderFooterView {
    fileprivate let titleButton: UIButton = UIButton()
    static let reuseIdentifier = "LeftMenuSectionFooterReuseIdentifier"
    var moreTapHandler : (() -> Void)?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleButton.frame = CGRect(x: 15, y: 0, width: 50, height: 29)
    }
}

extension LeftMenuSectionFooter : PrivateSetup {
    fileprivate func setup() {
        self.setupContentView()
        self.setupTitleButton()
    }
    
    fileprivate func setupTitleButton() {
        self.addSubview(self.titleButton)
        self.titleButton.setImage(UIImage(named: "common_arrow_icon_passive"), for: UIControlState())
        self.titleButton.titleLabel?.font = FontBucket.footerTitleFont
        self.titleButton.titleLabel?.textColor = ColorBucket.leftMenuMoreTextColor
        self.titleButton.setTitle("more ", for: UIControlState())
        self.titleButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        self.titleButton.titleLabel!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        self.titleButton.imageView!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        self.titleButton.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
    }
    
    fileprivate func setupContentView() {
        self.contentView.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
}

extension LeftMenuSectionFooter : Actions {
    func moreAction() {
        self.moreTapHandler!()
    }
}
