//
//  ConversationTitleView.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 04.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

private protocol Interface : class {
    func configureWithChannel(channel: Channel)
}

protocol ConversationTitleViewDelegate : class {
    func didTapTitleView()
}

final class ConversationTitleView : UIView {
    fileprivate let statusView: UIView = UIView()
    fileprivate let titleLabel: UILabel = UILabel()
    
    weak var delegate: ConversationTitleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        let labelWidth = frame.width - 20
        titleLabel.frame = CGRect(x: 15, y: 0, width: labelWidth, height: frame.height)
        titleLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        titleLabel.textColor = ColorBucket.blackColor
        titleLabel.font = FontBucket.titleChannelFont
        titleLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let dg = delegate else {return}
        
        dg.didTapTitleView()
    }
}

extension ConversationTitleView : Interface {
    func configureWithChannel(channel: Channel) {
        titleLabel.text = channel.displayName
    }
}
