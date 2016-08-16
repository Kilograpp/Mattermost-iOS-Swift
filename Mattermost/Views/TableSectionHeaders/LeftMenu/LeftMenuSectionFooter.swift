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
    private let titleButton: UIButton = UIButton()
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
        
        self.titleButton.frame = CGRectMake(15, 4, 47, 13)
    }
}

extension LeftMenuSectionFooter : PrivateSetup {
    private func setup() {
        self.setupContentView()
        self.setupTitleButton()
    }
    
    private func setupTitleButton() {
        self.addSubview(self.titleButton)
        self.titleButton.setImage(UIImage(named: "common_arrow_icon_passive"), forState: .Normal)
        self.titleButton.titleLabel?.font = FontBucket.footerTitleFont
        self.titleButton.setTitle("more ", forState: .Normal)
        self.titleButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.titleButton.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.titleButton.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.titleButton.addTarget(self, action: #selector(moreAction), forControlEvents: .TouchUpInside)
    }
    
    private func setupContentView() {
        self.contentView.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
}

extension LeftMenuSectionFooter : Actions {
    func moreAction() {
        self.moreTapHandler!()
    }
}