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
        
        titleButton.frame = CGRect(x: 15, y: 0, width: 50, height: 29)
    }
}

extension LeftMenuSectionFooter : PrivateSetup {
    fileprivate func setup() {
        self.setupContentView()
        self.setupTitleButton()
    }
    
    fileprivate func setupTitleButton() {
        addSubview(self.titleButton)
        titleButton.setImage(UIImage(named: "common_arrow_icon_passive"), for: UIControlState())
        titleButton.titleLabel?.font = FontBucket.footerTitleFont
        titleButton.setTitleColor(ColorBucket.sideMenuCommonTextColor, for: .normal)
        titleButton.setTitle("more ", for: UIControlState())
        titleButton.setTitleColor(ColorBucket.sideMenuCommonTextColor, for: .normal)
        titleButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        titleButton.titleLabel!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        titleButton.imageView!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        titleButton.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
    }
    
    fileprivate func setupContentView() {
        contentView.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
}

extension LeftMenuSectionFooter : Actions {
    func moreAction() {
        moreTapHandler!()
    }
}
